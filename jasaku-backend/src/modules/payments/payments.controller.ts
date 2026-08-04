import { Response } from "express";
import { PaymentsService } from "./payments.service";
import { AuthRequest } from "../../middleware/auth.middleware";
import { successResponse, errorResponse } from "../../utils/response";
import { NotificationService } from "../notifications/notifications.service";
import { prisma } from "../../config/prisma";
import { uploadToStorage } from "../../services/storage.service";

const getPaymentMethods = async (req: AuthRequest, res: Response) => {
  try {
    const result = await new PaymentsService().getPaymentMethods();
    return successResponse(res, result, "Metode pembayaran berhasil diambil");
  } catch (err: any) {
    return errorResponse(res, err.message);
  }
};

const createPayment = async (req: AuthRequest, res: Response) => {
  try {
    const { orderId, method, amount } = req.body;
    if (!orderId || !method || !amount) {
      return errorResponse(res, "orderId, method, dan amount wajib diisi", 400);
    }
    const profile = await prisma.profiles_customer.findUnique({
      where: { user_id: req.user!.userId }
    });
    if (!profile) return errorResponse(res, "Profil customer tidak ditemukan", 403);

    const result = await new PaymentsService().createPayment(orderId, method, amount, profile.id);
    return successResponse(res, result, "Pembayaran berhasil dibuat", 201);
  } catch (err: any) {
    return errorResponse(res, err.message, err.status || 500);
  }
};

const getPaymentByOrder = async (req: AuthRequest, res: Response) => {
  try {
    const orderId = String(req.params.orderId);
    const order = await prisma.orders.findUnique({
      where: { id: orderId },
      select: { customer_id: true, provider_id: true }
    });
    if (!order) return errorResponse(res, "Order tidak ditemukan", 404);

    const isAdmin = req.user!.role === 'admin';
    const customerProfile = await prisma.profiles_customer.findUnique({
      where: { user_id: req.user!.userId }
    });
    const providerProfile = await prisma.provider_profiles.findUnique({
      where: { user_id: req.user!.userId }
    });
    const isOwner =
      (customerProfile && order.customer_id === customerProfile.id) ||
      (providerProfile && order.provider_id === providerProfile.id);
    if (!isAdmin && !isOwner) return errorResponse(res, "Anda tidak berhak melihat pembayaran ini", 403);

    const result = await new PaymentsService().getPaymentByOrder(orderId);
    if (!result) return errorResponse(res, "Pembayaran tidak ditemukan", 404);
    return successResponse(res, result, "Detail pembayaran berhasil diambil");
  } catch (err: any) {
    return errorResponse(res, err.message, err.status || 500);
  }
};

const updatePaymentStatus = async (req: AuthRequest, res: Response) => {
  try {
    const paymentId = String(req.params.paymentId);
    const { status } = req.body;
    if (!['paid', 'failed', 'pending'].includes(status)) {
      return errorResponse(res, "Status harus 'paid', 'failed', atau 'pending'", 400);
    }

    const payment = await new PaymentsService().updatePaymentStatus(paymentId, status);
    if (!payment) return errorResponse(res, "Pembayaran tidak ditemukan", 404);

    // Notifikasi — cari user_id dari profile_id
    const order = await prisma.orders.findUnique({
      where: { id: payment.order_id },
      include: {
        profiles_customer: { select: { user_id: true } },
        provider_profiles: { select: { user_id: true } }
      }
    });
    if (order) {
      const customerUserId = order.profiles_customer?.user_id;
      const providerUserId = order.provider_profiles?.user_id;
      if (status === 'paid') {
        if (customerUserId) await NotificationService.sendToUser(customerUserId, "Pembayaran Berhasil", "Pembayaran Anda telah dikonfirmasi. Terima kasih!", { orderId: order.id, type: "PAYMENT_SUCCESS" });
        if (providerUserId) await NotificationService.sendToUser(providerUserId, "Pembayaran Diterima", "Pembayaran untuk pesanan telah diterima.", { orderId: order.id, type: "PAYMENT_RECEIVED" });
      } else if (status === 'failed') {
        if (customerUserId) await NotificationService.sendToUser(customerUserId, "Pembayaran Gagal", "Pembayaran Anda gagal. Silakan coba lagi.", { orderId: order.id, type: "PAYMENT_FAILED" });
      }
    }

    return successResponse(res, payment, `Status pembayaran berhasil diubah ke ${status}`);
  } catch (err: any) {
    return errorResponse(res, err.message);
  }
};

export { getPaymentMethods, createPayment, getPaymentByOrder, updatePaymentStatus, uploadPaymentProof };

const uploadPaymentProof = async (req: AuthRequest, res: Response) => {
  try {
    const orderId = String(req.params.orderId);
    const file = req.file;
    if (!file) return errorResponse(res, "Upload bukti pembayaran terlebih dahulu", 400);

    const profile = await prisma.profiles_customer.findUnique({
      where: { user_id: req.user!.userId }
    });
    if (!profile) return errorResponse(res, "Profil customer tidak ditemukan", 403);

    const fileUrl = await uploadToStorage(file.buffer, 'payment-proofs', file.originalname);
    const result = await new PaymentsService().uploadPaymentProof(orderId, fileUrl, profile.id);
    return successResponse(res, result, "Bukti pembayaran berhasil diupload");
  } catch (err: any) {
    return errorResponse(res, err.message, err.status || 500);
  }
};
