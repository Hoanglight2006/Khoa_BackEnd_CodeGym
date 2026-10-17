<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Login Page</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            margin-top: 100px;
            background-color: #f8fafc;
        }
        .login-container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            text-align: center;
        }
        input {
            padding: 10px;
            margin: 10px 0;
            width: 90%;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        button {
            background-color: #1b2a7a;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            width: 100%;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2 style="color: #1b2a7a;">System Login</h2>
        <!-- Form gửi dữ liệu bằng phương thức POST tới đường dẫn login -->
        <form action="login" method="POST">
            <input type="text" name="username" placeholder="Enter username" required />
            <br/>
            <input type="password" name="password" placeholder="Enter password" required />
            <br/>
            <button type="submit">Login</button>
        </form>
    </div>
</body>
</html>
