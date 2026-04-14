<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Mobile.Master" AutoEventWireup="true" CodeBehind="dashboard.aspx.cs" Inherits="pow.WebForm1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .welcome-page {
            min-height: calc(100vh - 64px);
            background: #efefef;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            padding: 40px 20px 30px 20px;
        }

        .welcome-wrap {
            width: 100%;
            max-width: 420px;
            text-align: center;
            padding-top: 60px;
        }

        .welcome-title {
            margin: 0 0 34px 0;
            font-size: 30px;
            font-weight: 400;
            color: #111;
            letter-spacing: 0.2px;
        }

        .logo-card {
            width: 150px;
            height: 150px;
            margin: 0 auto 34px auto;
            background: #f2a500;
            border: 3px solid #ffffff;
            border-radius: 18px;
            box-shadow: 0 10px 20px rgba(0,0,0,0.28);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        .logo-card img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .welcome-text {
            margin: 0;
            font-size: 16px;
            line-height: 1.45;
            color: #222;
        }

        @media (max-width: 480px) {
            .welcome-page {
                padding: 30px 16px 24px 16px;
            }

            .welcome-wrap {
                padding-top: 40px;
            }

            .welcome-title {
                font-size: 26px;
                margin-bottom: 28px;
            }

            .logo-card {
                width: 140px;
                height: 140px;
               

            }

            .welcome-text {
                font-size: 15px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="FeaturedContent" runat="server">
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="welcome-page">
        <div class="welcome-wrap">
            <h1 class="welcome-title">Hello Animal Lovers!</h1>

            <div class="logo-card">
               <img src="Content/images/logo.png" />
            </div>
            

            <p class="welcome-text">
                Welcome to PawSoS<br />
                Your companion for Animal care and Rescue
            </p>
        </div>
    </div>
</asp:Content>