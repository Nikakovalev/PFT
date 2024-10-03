import Http "mo:base/Http";
import Cryptography "mo:cryptography";
import Time "mo:base/Time";

actor FinanceTracker {
    type Transaction = {
        id: Int;
        amount: Int;
        description: Text;
        date: Nat64; // timestamp transaksi
        userId: Int; // ID pengguna yang memiliki transaksi ini
    };

    type User = {
        id: Int;
        username: Text;
        password: Text; // Hash password
        salt: Text; // Salt untuk password
    };

    stable var transactions: [Transaction] = []; // Menyimpan semua transaksi
    stable var users: [User] = []; // Menyimpan semua pengguna
    stable var currentUserId: Int = 0; // Menyimpan ID pengguna yang sedang login
    stable var otpStore: [Int] = []; // Menyimpan OTP yang dikirim ke pengguna
    stable var otpEmailStore: [Text] = []; // Menyimpan email untuk OTP

    // Ambil API Key dari variabel lingkungan
    let sendGridApiKey = System.env("SENDGRID_API_KEY") ? "default-value" : "default-value"; // Ganti dengan nilai default jika tidak ditemukan

    // Fungsi untuk menghasilkan salt acak
    private func generateSalt(): Text {
        return Cryptography.randomText(16); // Menghasilkan 16 karakter random
    }

    // Fungsi untuk mengirim email menggunakan SendGrid
    private func sendEmail(to: Text, subject: Text, body: Text): async Bool {
        let url = "https://api.sendgrid.com/v3/mail/send";
        let headers = [
            Http.Header.Field("Authorization", "Bearer " # sendGridApiKey),
            Http.Header.Field("Content-Type", "application/json")
        ];

        let emailData = {
            "personalizations": [{
                "to": [{
                    "email": to
                }],
                "subject": subject
            }],
            "from": {
                "email": "your-email@example.com" // Ganti dengan alamat email Anda yang terverifikasi di SendGrid
            },
            "content": [{
                "type": "text/plain",
                "value": body
            }]
        };

        let response = await Http.post(url, headers, Json.serialize(emailData));
        return response.status == 202; // Mengembalikan true jika email berhasil dikirim
    }

    public func register(username: Text, password: Text): Int {
        let salt = generateSalt(); // Menghasilkan salt
        let hashedPassword = Cryptography.sha256(password # salt); // Hash password dengan salt
        let newUserId = Array.size(users) + 1;
        let newUser = {
            id = newUserId;
            username = username;
            password = hashedPassword; // Simpan password yang telah di-hash
            salt = salt; // Simpan salt
        };
        users := Array.append(users, [newUser]);
        return newUserId;
    }

    public func login(username: Text, password: Text): Bool {
        for (user in users) {
            if (user.username == username) {
                let hashedPassword = Cryptography.sha256(password # user.salt); // Hash dengan salt pengguna
                if (user.password == hashedPassword) {
                    currentUserId := user.id;
                    return true; // Login berhasil
                }
            }
        }
        return false; // Login gagal
    }

    public func logout(): void {
        currentUserId := 0; // Reset ID pengguna yang sedang login
    }

    public func addTransaction(amount: Int, description: Text): Int {
        let id = Array.size(transactions) + 1;
        let newTransaction = {
            id = id;
            amount = amount;
            description = description;
            date = Time.now(); // Mendapatkan timestamp saat ini
            userId = currentUserId; // Kaitkan transaksi dengan pengguna yang login
        };
        transactions := Array.append(transactions, [newTransaction]);
        stable transactions; // Menyimpan transaksi secara stabil
        return id;
    }

    public func deleteTransaction(id: Int): Bool {
        let index = Array.findIndex(transactions, func(txn) { txn.id == id });
        switch (index) {
            case (?indexValue) {
                transactions := Array.remove(transactions, indexValue); // Menghapus transaksi berdasarkan indeks
                stable transactions; // Menyimpan perubahan secara stabil
                return true; // Mengembalikan true jika berhasil
            };
            case null {
                return false; // Mengembalikan false jika transaksi tidak ditemukan
            };
        }
    }

    public func updateTransaction(id: Int, amount: Int, description: Text): Bool {
        let index = Array.findIndex(transactions, func(txn) { txn.id == id });
        switch (index) {
            case (?indexValue) {
                let updatedTransaction = {
                    id = id;
                    amount = amount;
                    description = description;
                    date = transactions[indexValue].date; // Menggunakan tanggal lama
                    userId = transactions[indexValue].userId; // Mempertahankan userId
                };
                transactions[indexValue] := updatedTransaction; // Memperbarui transaksi
                stable transactions; // Menyimpan perubahan secara stabil
                return true; // Mengembalikan true jika berhasil
            };
            case null {
                return false; // Mengembalikan false jika transaksi tidak ditemukan
            };
        }
    }

    public query func getTransactions(): [Transaction] {
        return transactions; // Mengembalikan daftar semua transaksi
    }

    public query func getUserTransactions(): [Transaction] {
        return Array.filter(transactions, func(txn) { txn.userId == currentUserId }); // Mengembalikan transaksi berdasarkan pengguna
    }

    public query func searchTransactions(query: Text): [Transaction] {
        return Array.filter(getUserTransactions(), func(txn) {
            Text.indexOf(txn.description, query) != null // Mencari deskripsi yang mengandung query
        });
    }

    public query func filterTransactions(startDate: Nat64, endDate: Nat64): [Transaction] {
        return Array.filter(getUserTransactions(), func(txn) {
            txn.date >= startDate && txn.date <= endDate // Memfilter transaksi berdasarkan rentang tanggal
        });
    }

    // Fungsi untuk menghasilkan dan mengirim OTP
    public async func sendOTP(username: Text, email: Text): async Int {
        let otp = Cryptography.randomInt(100000, 999999); // Menghasilkan OTP 6 digit
        otpStore := Array.append(otpStore, otp); // Simpan OTP untuk verifikasi
        otpEmailStore := Array.append(otpEmailStore, email); // Simpan email terkait dengan OTP

        // Kirim OTP ke email pengguna
        let subject = "Your OTP Code";
        let body = "Your OTP code is: " # Int.toText(otp);
        let emailSent = await sendEmail(email, subject, body);

        if (emailSent) {
            return otp; // Kembalikan OTP untuk referensi jika email berhasil dikirim
        } else {
            return -1; // Mengembalikan -1 jika gagal mengirim email
        }
    }

    // Fungsi untuk memverifikasi OTP
    public func verifyOTP(inputOtp: Int, email: Text): Bool {
        let index = Array.findIndex(otpStore, func(o) { o == inputOtp });
        let emailIndex = Array.findIndex(otpEmailStore, func(e) { e == email });
        
        if (index != null && emailIndex == index) {
            otpStore := Array.remove(otpStore, index); // Hapus OTP setelah diverifikasi
            otpEmailStore := Array.remove(otpEmailStore, index); // Hapus email yang sesuai
            return true; // OTP valid
        }
        return false; // OTP tidak valid
    }
}

