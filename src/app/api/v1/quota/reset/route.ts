import { db } from '@/db';
import { NextResponse } from 'next/server';

export async function POST() {
  try {
    const now = new Date();
    const quotas = await db.quota.findMany();

    for (const quota of quotas) {
      await db.quota.update({
        where: { id: quota.id },
        data: {
          count: 0,
          year: now.getFullYear(),
          month: now.getMonth() + 1,
          resetAt: now
        }
      });
    }

    return NextResponse.json({ message: 'All quotas reset successfully' });
  } catch (error) {
    console.error('Error resetting quotas:', error);
    return NextResponse.json(
      { message: 'Failed to reset quotas' },
      { status: 500 }
    );
  }
}