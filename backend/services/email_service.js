const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

const sendResetEmail = async (email, token) => {
  const resetLink = `http://localhost:3000/reset-password.html?token=${token}`; // For demo/simplicity, using a local html file

  const mailOptions = {
    from: `"GoFood Support" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Reset Your GoFood Password',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e0e0e0; border-radius: 10px; overflow: hidden;">
        <div style="background-color: #f8f9fa; padding: 20px; text-align: center;">
          <h1 style="color: #FF5252; margin: 0;">GoFood</h1>
        </div>
        <div style="padding: 30px;">
          <h2 style="color: #333;">Password Reset Request</h2>
          <p style="color: #555; font-size: 16px; line-height: 1.5;">
            Hi there,
          </p>
          <p style="color: #555; font-size: 16px; line-height: 1.5;">
            We received a request to reset your password for your GoFood account. Click the button below to choose a new password:
          </p>
          <div style="text-align: center; margin: 30px 0;">
            <a href="${resetLink}" style="background-color: #FF5252; color: white; padding: 15px 25px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 16px;">Reset Password</a>
          </div>
          <p style="color: #888; font-size: 14px; line-height: 1.5;">
            If you didn't request a password reset, you can safely ignore this email. This link will expire in 1 hour.
          </p>
        </div>
        <div style="background-color: #f8f9fa; padding: 20px; text-align: center; color: #888; font-size: 12px;">
          © 2024 GoFood. All rights reserved.
        </div>
      </div>
    `,
  };

  return transporter.sendMail(mailOptions);
};

module.exports = {
  sendResetEmail,
};
