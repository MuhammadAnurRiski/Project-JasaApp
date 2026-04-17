import { prisma } from '../../config/prisma';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

export class AuthService {
  async register(email: string, password: string, role: 'customer' | 'jasa', name: string) {
    const existing = await prisma.users.findUnique({ where: { email } });
    if (existing) throw new Error('Email sudah terdaftar');

    const hashedPassword = await bcrypt.hash(password, 12);
    
    // Gunakan transaction agar atomic
    const user = await prisma.$transaction(async (tx) => {
      const newUser = await tx.users.create({
        data: { email, password: hashedPassword, role }
      });

      if (role === 'customer') {
        await tx.customer_profiles.create({
          data: { user_id: newUser.id, name }
        });
      } else {
        await tx.provider_profiles.create({
          data: { user_id: newUser.id, name, is_verified: false }
        });
      }

      return newUser;
    });

    return this.generateToken(user.id, user.role);
  }

  async login(email: string, password: string) {
    const user = await prisma.users.findUnique({ where: { email } });
    if (!user) throw new Error('Email atau password salah');

    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) throw new Error('Email atau password salah');

    const token = this.generateToken(user.id, user.role);
    
    // Ambil profile sesuai role
    let profile = null;
    if (user.role === 'customer') {
      profile = await prisma.customer_profiles.findUnique({ where: { user_id: user.id } });
    } else if (user.role === 'jasa') {
      profile = await prisma.provider_profiles.findUnique({ where: { user_id: user.id } });
    }

    return { token, user: { id: user.id, email: user.email, role: user.role }, profile };
  }

  private generateToken(userId: string, role: string) {
    return jwt.sign(
      { userId, role },
      process.env.JWT_SECRET!,
      { expiresIn: process.env.JWT_EXPIRES_IN as any }
    );
  }
}