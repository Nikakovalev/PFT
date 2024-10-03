# Personal Finance Tracker

Personal Finance Tracker is an application designed to help users effectively manage their finances. The app allows users to record, search, and filter their financial transactions. It is built using **Internet Computer (DFINITY)** for the backend with **Motoko** and **React** for the frontend.

## Features
- **Register & Login**: Users can create accounts and log in securely.
- **OTP Security**: Users are verified using a One-Time Password (OTP) sent via email.
- **Transactions**: Add, update, and delete transactions.
- **Search & Filter**: Users can search for specific transactions or filter by date range.
- **Password Security**: User passwords are hashed before storage to ensure security.

## Technologies Used
- **Backend**: 
  - **Motoko** - A language used on Internet Computer for writing application logic.
  - **SendGrid API** - For sending OTP verification emails.
  - **Cryptography** - Used for password hashing and OTP generation.
  
- **Frontend**:
  - **React** - For building a dynamic user interface.
  - **Axios** - To make HTTP requests to the backend.
  - **React Router** - To manage page navigation.


## Installation and Usage

### 1. Running the Backend
Ensure you have the Internet Computer SDK installed. You can run the backend with the following commands:
```bash
dfx start --background
dfx deploy
```

### 2. Running the Frontend
For the frontend, install the dependencies using npm and start the React application:
```bash
cd frontend
npm install
npm start
```

Access the app in your browser at `http://localhost:3000`.

### 3. Configuring the SendGrid API Key
For OTP delivery, create a SendGrid account and get an API key. Store the API key in the `.env` file in the backend as follows:
```
SENDGRID_API_KEY=your-api-key-here
```

### 4. Using the Application
1. **Register**: Create a new account on the `/register` page.
2. **Login**: Log into your account on the `/login` page.
3. **OTP Verification**: Verify your account using the OTP code sent to your email.
4. **Transactions**: Add, update, delete, and search your financial transactions.

## Further Development
- **Additional Security**: Implement two-factor authentication (2FA), data encryption, and other security enhancements.
- **UI/UX Improvements**: Enhance the app's appearance and interaction for a better user experience.
- **Advanced Features**: Add financial analytics or integrate with banking services.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the [MIT License](LICENSE).
