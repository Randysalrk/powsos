<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="pow.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>PawSoS - Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Arial, sans-serif;
            background: #efefef;
        }

        .login-page {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            padding: 40px 18px;
            background: #efefef;
        }

        .login-wrap {
            width: 100%;
            max-width: 360px;
            text-align: center;
            padding-top: 18px;
        }

        .brand {
            font-size: 32px;
            font-weight: 400;
            margin-bottom: 44px;
            letter-spacing: 0.3px;
        }

        .brand-paw {
            color: #f0a51a;
        }

        .brand-sos {
            color: #444;
        }

        .login-title {
            text-align: left;
            font-size: 32px;
            font-weight: 400;
            color: #1c1c1c;
            margin: 0 0 18px 0;
        }

        .input-box {
            width: 100%;
            height: 44px;
            border: none;
            outline: none;
            background: #d9d9d9;
            border-radius: 5px;
            padding: 0 14px;
            font-size: 15px;
            color: #333;
            margin-bottom: 12px;
        }

        .input-box::placeholder {
            color: #8c8c8c;
        }

        .forgot-wrap {
            text-align: left;
            margin: 6px 0 18px 0;
        }

        .forgot-link {
            font-size: 14px;
            color: #666;
            text-decoration: none;
        }

        .forgot-link:hover {
            text-decoration: underline;
        }

        .login-btn {
            width: 100%;
            height: 46px;
            border: none;
            border-radius: 6px;
            background: #f0b23a;
            color: #1f1f1f;
            font-size: 19px;
            font-weight: 400;
            cursor: pointer;
            transition: 0.2s ease;
        }

        .login-btn:hover {
            background: #e4a62d;
        }

        .register-text-top {
            margin-top: 34px;
            font-size: 12px;
            color: #444;
        }

        .register-line {
            margin-top: 10px;
            font-size: 13px;
            color: #555;
        }

        .basic-link {
            color: #f0a51a;
            text-decoration: none;
            margin-right: 4px;
        }

        .basic-link:hover {
            text-decoration: underline;
        }

        .register-line-2 {
            margin-top: 8px;
            font-size: 13px;
            color: #555;
        }

        @media (max-width: 480px) {
            .brand {
                font-size: 28px;
                margin-bottom: 38px;
            }

            .login-title {
                font-size: 30px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-page">
            <div class="login-wrap">

                <div class="brand">
                    <span class="brand-paw">Paw</span><span class="brand-sos">SoS</span>
                </div>

                <h1 class="login-title">Login</h1>

                <asp:TextBox ID="txtEmail" runat="server" CssClass="input-box" TextMode="Email" placeholder="Email address"></asp:TextBox>

                <asp:TextBox ID="txtPassword" runat="server" CssClass="input-box" TextMode="Password" placeholder="Password"></asp:TextBox>

                <div class="forgot-wrap">
                    <a href="#" class="forgot-link">Forgot password?</a>
                </div>

                <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="login-btn" />

                <div class="register-text-top">
                    Are you still not a member?
                </div>

                <div class="register-line">
                    <a href="#" class="basic-link">Basic user</a>
                    or
                    <a href="#" class="basic-link">Organization</a>
                </div>

                <div class="register-line-2">
                    create a new account here
                </div>

            </div>
        </div>
    </form>
</body>
</html>