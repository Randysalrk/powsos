<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Mobile.Master" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs" Inherits="pow.Notifications" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .notify-page {
            max-width: 380px;
            margin: 0 auto;
            padding: 16px 12px 30px;
            background: #efefef;
            min-height: 100vh;
            box-sizing: border-box;
        }

        .page-title {
            font-size: 28px;
            color: #d79a18;
            text-align: center;
            margin: 10px 0 18px;
            font-weight: 600;
        }

        .section-title {
            font-size: 18px;
            font-weight: 600;
            color: #222;
            margin: 10px 0 14px;
        }

        .notify-card {
            background: #fff;
            border-radius: 14px;
            padding: 14px;
            margin-bottom: 16px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            border: 1px solid #ddd;
        }

        .notify-line {
            font-size: 15px;
            color: #333;
            margin-bottom: 10px;
            line-height: 1.5;
        }

        .btn-main {
            width: 100%;
            background: #e0a52b;
            color: #111;
            border: none;
            border-radius: 8px;
            padding: 12px;
            font-weight: 700;
            font-size: 16px;
            cursor: pointer;
        }

        .btn-main:hover {
            background: #d49716;
        }

        .empty-box {
            background: #fff;
            border: 1px dashed #bbb;
            border-radius: 14px;
            padding: 20px;
            text-align: center;
            color: #666;
            font-size: 15px;
        }

        /* Modal */
        .modal-overlay {
            position: fixed;
            top: 0; left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.45);
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 15px;
            box-sizing: border-box;
        }

        .modal-box {
            width: 100%;
            max-width: 360px;
            background: #fff;
            border-radius: 16px;
            padding: 18px;
            box-sizing: border-box;
            box-shadow: 0 8px 24px rgba(0,0,0,0.2);
        }

        .modal-title {
            font-size: 22px;
            font-weight: 700;
            color: #d79a18;
            text-align: center;
            margin-bottom: 16px;
        }

        .modal-text {
            font-size: 15px;
            color: #333;
            margin-bottom: 10px;
            line-height: 1.5;
        }

        .modal-actions {
            display: flex;
            gap: 10px;
            margin-top: 18px;
        }

        .btn-accept, .btn-reject, .btn-close {
            flex: 1;
            border: none;
            border-radius: 8px;
            padding: 12px;
            font-weight: 700;
            font-size: 15px;
            cursor: pointer;
        }

        .btn-accept {
            background: #28a745;
            color: #fff;
        }

        .btn-reject {
            background: #dc3545;
            color: #fff;
        }

        .btn-close {
            background: #6c757d;
            color: #fff;
            margin-top: 10px;
            width: 100%;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notify-page">
        <div class="page-title">Notifications</div>

        <div class="section-title">Received Alerts</div>

        <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
            <ItemTemplate>
                <div class="notify-card">
                    <div class="notify-line"><strong>Alert ID:</strong> <%# Eval("AlertId") %></div>
                    <div class="notify-line"><strong>Raised By:</strong> <%# Eval("RaisedByName") %></div>
                    <div class="notify-line"><strong>Sent Time:</strong> <%# Eval("SentAt", "{0:yyyy-MM-dd hh:mm tt}") %></div>
                    <div class="notify-line"><strong>Status:</strong> <%# Eval("NotificationStatus") %></div>

                    <asp:LinkButton ID="btnViewDetails" runat="server" CssClass="btn-main"
                        CommandName="ViewDetails"
                        CommandArgument='<%# Eval("NotificationId") %>'>
                        View Details
                    </asp:LinkButton>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-box">
            No notifications available.
        </asp:Panel>
    </div>

    <!-- Modal -->
    <asp:Panel ID="pnlModal" runat="server" Visible="false" CssClass="modal-overlay">
        <div class="modal-box">
            <div class="modal-title">Alert Details</div>

            <asp:HiddenField ID="hfNotificationId" runat="server" />
            <asp:HiddenField ID="hfAlertId" runat="server" />

            <div class="modal-text"><strong>Alert ID:</strong> <asp:Label ID="lblAlertId" runat="server" /></div>
            <div class="modal-text"><strong>Raised By:</strong> <asp:Label ID="lblRaisedBy" runat="server" /></div>
            <div class="modal-text"><strong>Description:</strong> <asp:Label ID="lblDescription" runat="server" /></div>
            <div class="modal-text"><strong>Animal Type:</strong> <asp:Label ID="lblAnimalType" runat="server" /></div>
            <div class="modal-text"><strong>Found Location:</strong> <asp:Label ID="lblLocationText" runat="server" /></div>
            <div class="modal-text"><strong>Latitude:</strong> <asp:Label ID="lblLatitude" runat="server" /></div>
            <div class="modal-text"><strong>Longitude:</strong> <asp:Label ID="lblLongitude" runat="server" /></div>
            <div class="modal-text"><strong>Sent Time:</strong> <asp:Label ID="lblSentTime" runat="server" /></div>

            <div class="modal-actions">
                <asp:Button ID="btnAccept" runat="server" Text="Accept" CssClass="btn-accept" OnClick="btnAccept_Click" />
                <asp:Button ID="btnReject" runat="server" Text="Reject" CssClass="btn-reject" OnClick="btnReject_Click" />
            </div>

            <asp:Button ID="btnClose" runat="server" Text="Close" CssClass="btn-close" OnClick="btnClose_Click" />
        </div>
    </asp:Panel>
</asp:Content>