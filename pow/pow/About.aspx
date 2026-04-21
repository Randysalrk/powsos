<%@ Page Title="About POW SOS" Language="C#" MasterPageFile="~/Site.Mobile.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="pow.WebForm2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <style>
        .about-page {
            max-width: 420px;
            margin: 0 auto;
            padding: 16px 14px 30px;
            background: #efefef;
            min-height: 100vh;
            font-family: Arial, sans-serif;
        }

        .hero-card {
            background: linear-gradient(135deg, #d89a15, #f1bc4b);
            border-radius: 24px;
            padding: 26px 20px;
            color: #fff;
            text-align: center;
            margin-bottom: 18px;
        }

        .hero-title {
            font-size: 26px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .hero-subtitle {
            font-size: 14px;
            line-height: 1.6;
        }

        .info-card {
            background: #fff;
            border-radius: 18px;
            padding: 16px;
            margin-bottom: 14px;
        }

        .section-title {
            font-size: 16px;
            font-weight: 700;
            color: #d79a18;
            margin-bottom: 10px;
        }

        .section-text {
            font-size: 14px;
            color: #444;
            line-height: 1.7;
        }

        .mini-list {
            padding-left: 18px;
        }

        .mini-list li {
            margin-bottom: 8px;
            font-size: 14px;
        }

        .feature-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }

        .feature-box {
            background: #faf7f0;
            padding: 12px;
            border-radius: 14px;
            text-align: center;
            border: 1px solid #f0e2b8;
        }

        .feature-title {
            font-size: 13px;
            font-weight: bold;
            margin-bottom: 4px;
        }

        .feature-desc {
            font-size: 12px;
            color: #666;
        }

        .stat-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 8px;
        }

        .stat-box {
            background: #fff8e9;
            padding: 12px;
            border-radius: 14px;
            text-align: center;
        }

        .stat-number {
            font-weight: bold;
            color: #d79a18;
        }

        .contact-card {
            background: #333;
            color: #fff;
            border-radius: 18px;
            padding: 16px;
            text-align: center;
        }

        .contact-btn {
            display: inline-block;
            margin-top: 10px;
            padding: 10px 18px;
            background: #d79a18;
            color: #fff;
            border-radius: 25px;
            text-decoration: none;
        }

        .footer-note {
            text-align: center;
            font-size: 12px;
            color: #777;
            margin-top: 15px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="FeaturedContent" runat="server">
    <!-- Optional: you can leave empty or add banner -->
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <div class="about-page">

        <!-- HERO -->
        <div class="hero-card">
            <div style="font-size:40px;">🐾</div>
            <div class="hero-title">POW SOS</div>
            <div class="hero-subtitle">
                Animal Care & Rescue Alert System that connects people and organizations to save animals in need.
            </div>
        </div>

        <!-- ABOUT -->
        <div class="info-card">
            <div class="section-title">About the Application</div>
            <div class="section-text">
                POW SOS is an animal rescue platform that allows users to report helpless animals instantly. 
                If someone sees an injured, sick, or abandoned animal but cannot help at that moment, they can send an alert with location and photo proof to nearby organizations with just one click.
            </div>
        </div>

        <!-- HOW IT WORKS -->
        <div class="info-card">
            <div class="section-title">How It Works</div>
            <ul class="mini-list">
                <li>Find an animal that needs help</li>
                <li>Take a picture as proof</li>
                <li>Click once to send alert</li>
                <li>Nearby organizations receive notification</li>
                <li>They take action and rescue the animal</li>
            </ul>
        </div>

        <!-- MISSION -->
        <div class="info-card">
            <div class="section-title">Our Mission</div>
            <div class="section-text">
                To ensure no helpless animal is ignored by creating a fast and reliable connection between the public and rescue organizations.
            </div>
        </div>

        <!-- FEATURES -->
        <div class="info-card">
            <div class="section-title">Key Features</div>

            <div class="feature-grid">
                <div class="feature-box">
                    <div class="feature-title">🚨 One Click Alert</div>
                    <div class="feature-desc">Instantly notify organizations</div>
                </div>

                <div class="feature-box">
                    <div class="feature-title">📷 Photo Proof</div>
                    <div class="feature-desc">Upload animal condition image</div>
                </div>

                <div class="feature-box">
                    <div class="feature-title">📍 Location</div>
                    <div class="feature-desc">Send exact animal location</div>
                </div>

                <div class="feature-box">
                    <div class="feature-title">🏥 Organizations</div>
                    <div class="feature-desc">Nearby rescue support</div>
                </div>
            </div>
        </div>

        <!-- WHY -->
        <div class="info-card">
            <div class="section-title">Why This Matters</div>
            <ul class="mini-list">
                <li>Faster rescue for animals</li>
                <li>Anyone can help even if busy</li>
                <li>Better coordination</li>
                <li>Reliable proof-based alerts</li>
            </ul>
        </div>

        <!-- STATS -->
        <div class="info-card">
            <div class="section-title">Quick Overview</div>
            <div class="stat-row">
                <div class="stat-box">
                    <div class="stat-number">1 Tap</div>
                    <div>Alert</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">Photo</div>
                    <div>Proof</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">Nearby</div>
                    <div>Rescue</div>
                </div>
            </div>
        </div>

        <!-- CONTACT -->
        <div class="contact-card">
            <div>Need Help or Want to Join?</div>
            <div style="font-size:13px; margin-top:5px;">
                Contact us or register your organization to support animal rescue.
            </div>
            <a href="Contact.aspx" class="contact-btn">Contact</a>
        </div>

        <!-- FOOTER -->
        <div class="footer-note">
            POW SOS © <%: DateTime.Now.Year %><br />
            Helping Animals. Saving Lives.
        </div>

    </div>

</asp:Content>