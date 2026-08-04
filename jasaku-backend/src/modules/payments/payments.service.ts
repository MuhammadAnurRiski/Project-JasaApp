import {prisma} from '../../config/prisma';

export class PaymentsService {
    async getPaymentMethods() {
        const [banks, ewallets, qris] = await Promise.all([
            prisma.admin_bank_accounts.findMany({ where: { is_active: true }, orderBy: { created_at: 'asc' } }),
            prisma.admin_ewallet_accounts.findMany({ where: { is_active: true }, orderBy: { created_at: 'asc' } }),
            prisma.admin_qris_accounts.findMany({ where: { is_active: true }, orderBy: { created_at: 'asc' } }),
        ]);
        return [
            ...banks.map(a => ({
                id: `transfer_${a.id}`,
                type: 'Transfer Bank',
                description: `${a.provider_name} - ${a.account_name}`,
                account_name: a.account_name,
                account_number: a.account_number,
                provider_name: a.provider_name,
                qris_image_url: null,
                icon: 'account_balance',
            })),
            ...ewallets.map(a => ({
                id: `ewallet_${a.id}`,
                type: 'E-Wallet',
                description: `${a.provider_name} - ${a.account_name}`,
                account_name: a.account_name,
                account_number: a.account_number,
                provider_name: a.provider_name,
                qris_image_url: null,
                icon: 'wallet',
            })),
            ...qris.map(a => ({
                id: `qris_${a.id}`,
                type: 'QRIS',
                description: a.provider_name,
                account_name: null,
                account_number: null,
                provider_name: a.provider_name,
                qris_image_url: a.qris_image_url,
                icon: 'qr_code',
            })),
        ];
    }

    async createPayment(orderId: string, method: string, amount: number, customerProfileId: string) {
        const order = await prisma.orders.findUnique({
            where: { id: orderId },
            select: { id: true, customer_id: true, custom_task_id: true, status: true, total_price: true, platform_fee: true }
        });
        if (!order || order.custom_task_id) {
            const err: any = new Error('Order tidak ditemukan');
            err.status = 404;
            throw err;
        }
        if (order.customer_id !== customerProfileId) {
            const err: any = new Error('Anda tidak berhak atas order ini');
            err.status = 403;
            throw err;
        }
        if (order.status !== 'pending_payment') {
            const err: any = new Error('Order tidak dalam status menunggu pembayaran');
            err.status = 400;
            throw err;
        }
        const expected = Number(order.total_price || 0) + Number(order.platform_fee || 0);
        if (Math.abs(Number(amount) - expected) > 0.001) {
            const err: any = new Error(`Nominal pembayaran tidak sesuai. Total yang harus dibayar adalah ${expected.toLocaleString('id-ID')}`);
            err.status = 400;
            throw err;
        }

        const existing = await prisma.payments.findFirst({
            where: { order_id: orderId, method: { not: 'extension' } }
        });
        if (existing) {
            return await prisma.payments.update({
                where: { id: existing.id },
                data: { method, amount }
            });
        }
        return await prisma.payments.create({
            data: {
                order_id: orderId,
                method,
                amount,
                status: 'pending'
            }
        });
    }

    async updatePaymentStatus(paymentId: string, status: string) {
        const data: any = { status };
        if (status === 'paid') data.paid_at = new Date();
        return await prisma.payments.update({
            where: { id: paymentId },
            data
        });
    }

    async getPaymentByOrder(orderId: string) {
        return await prisma.payments.findFirst({
            where: { order_id: orderId }
        });
    }

    async uploadPaymentProof(orderId: string, fileUrl: string, customerProfileId: string) {
        const order = await prisma.orders.findUnique({
            where: { id: orderId },
            select: { id: true, customer_id: true, custom_task_id: true, status: true }
        });
        if (!order || order.custom_task_id) {
            const err: any = new Error('Order tidak ditemukan');
            err.status = 404;
            throw err;
        }
        if (order.customer_id !== customerProfileId) {
            const err: any = new Error('Anda tidak berhak atas order ini');
            err.status = 403;
            throw err;
        }
        if (!['pending_payment', 'pending'].includes(order.status || '')) {
            const err: any = new Error('Order sudah tidak menerima bukti pembayaran');
            err.status = 400;
            throw err;
        }

        let payment = await prisma.payments.findFirst({
            where: { order_id: orderId }
        });
        if (!payment) {
            payment = await prisma.payments.create({
                data: {
                    order_id: orderId,
                    status: 'pending',
                    payment_proof: fileUrl,
                }
            });
        } else {
            payment = await prisma.payments.update({
                where: { id: payment.id },
                data: { payment_proof: fileUrl }
            });
        }
        return payment;
    }
}


