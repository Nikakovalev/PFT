
import React, { useState } from 'react';
import axios from 'axios';

const OTPVerification = ({ email }) => {
    const [otp, setOtp] = useState('');

    const handleVerifyOtp = async (e) => {
        e.preventDefault();
        try {
            const response = await axios.post('/verify-otp', { email, otp });
            if (response.data.success) {
                console.log('OTP verified successfully!');
            } else {
                console.error('Invalid OTP');
            }
        } catch (error) {
            console.error('Error verifying OTP:', error);
        }
    };

    return (
        <form onSubmit={handleVerifyOtp}>
            <input
                type="text"
                placeholder="Enter OTP"
                value={otp}
                onChange={(e) => setOtp(e.target.value)}
                required
            />
            <button type="submit">Verify OTP</button>
        </form>
    );
};

export default OTPVerification;
                