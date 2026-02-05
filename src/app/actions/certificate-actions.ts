'use server';

import { createClient } from '@/utils/supabase/server';
import { z } from 'zod';
import crypto from 'crypto';

export interface Certificate {
    id: string;
    user_id: string;
    course_id: string;
    verification_code: string;
    issued_at: string;
    created_at: string;
}

export interface CertificateWithUser extends Certificate {
    user_name: string;
    user_email: string;
}

/**
 * Generate a certificate for a user who completed a course
 */
export async function generateCertificate(courseId: string) {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        return { error: 'Not authenticated' };
    }

    // Validate course exists
    if (!courseId || courseId.trim() === '') {
        return { error: 'Invalid course ID' };
    }

    // Check if user already has a certificate for this course
    const { data: existing } = await supabase
        .from('certificates')
        .select('*')
        .eq('user_id', user.id)
        .eq('course_id', courseId)
        .single();

    if (existing) {
        return {
            success: true,
            certificate: existing as Certificate,
            message: 'Certificate already exists'
        };
    }

    // Generate unique verification code
    const verificationCode = crypto.randomBytes(16).toString('hex');

    // Insert certificate
    const { data: certificate, error } = await supabase
        .from('certificates')
        .insert({
            user_id: user.id,
            course_id: courseId,
            verification_code: verificationCode,
        })
        .select()
        .single();

    if (error) {
        console.error('Certificate generation error:', error);
        return { error: 'Failed to generate certificate' };
    }

    return {
        success: true,
        certificate: certificate as Certificate
    };
}

/**
 * Get a specific certificate by ID
 */
export async function getCertificate(certificateId: string) {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        return { error: 'Not authenticated' };
    }

    const { data: certificate, error } = await supabase
        .from('certificates')
        .select('*')
        .eq('id', certificateId)
        .single();

    if (error || !certificate) {
        return { error: 'Certificate not found' };
    }

    return {
        success: true,
        certificate: certificate as Certificate
    };
}

/**
 * Verify a certificate using its verification code (public endpoint)
 */
export async function verifyCertificate(verificationCode: string) {
    const supabase = await createClient();

    if (!verificationCode || verificationCode.trim() === '') {
        return { error: 'Invalid verification code' };
    }

    // Use service role to bypass RLS for public verification
    const { data: certificate, error } = await supabase
        .from('certificates')
        .select(`
      id,
      user_id,
      course_id,
      verification_code,
      issued_at,
      created_at
    `)
        .eq('verification_code', verificationCode)
        .single();

    if (error || !certificate) {
        return {
            success: false,
            error: 'Invalid or expired certificate'
        };
    }

    // Get user info (first name + last initial for privacy)
    const { data: profile } = await supabase
        .from('profiles')
        .select('full_name, email')
        .eq('id', certificate.user_id)
        .single();

    // Format name for privacy: "Ola N." instead of full name
    let displayName = 'Unknown User';
    if (profile?.full_name) {
        const nameParts = profile.full_name.trim().split(' ');
        if (nameParts.length > 1) {
            const firstName = nameParts[0];
            const lastInitial = nameParts[nameParts.length - 1][0];
            displayName = `${firstName} ${lastInitial}.`;
        } else {
            displayName = nameParts[0];
        }
    }

    return {
        success: true,
        certificate: {
            ...certificate,
            user_name: displayName,
        } as CertificateWithUser
    };
}

/**
 * Get all certificates for a user (admin can specify userId, otherwise gets own)
 */
export async function getUserCertificates(userId?: string) {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        return { error: 'Not authenticated' };
    }

    let targetUserId = user.id;

    // If userId is provided, check if requester is admin
    if (userId && userId !== user.id) {
        const { data: profile } = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single();

        if (profile?.role !== 'admin') {
            return { error: 'Unauthorized' };
        }

        targetUserId = userId;
    }

    const { data: certificates, error } = await supabase
        .from('certificates')
        .select('*')
        .eq('user_id', targetUserId)
        .order('issued_at', { ascending: false });

    if (error) {
        console.error('Error fetching certificates:', error);
        return { error: 'Failed to fetch certificates' };
    }

    return {
        success: true,
        certificates: certificates as Certificate[]
    };
}

/**
 * Get all certificates (admin only)
 */
export async function getAllCertificates() {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        return { error: 'Not authenticated' };
    }

    // Verify admin
    const { data: profile } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    if (profile?.role !== 'admin') {
        return { error: 'Unauthorized' };
    }

    const { data: certificates, error } = await supabase
        .from('certificates')
        .select(`
      *,
      profiles!inner (
        full_name,
        email
      )
    `)
        .order('issued_at', { ascending: false });

    if (error) {
        console.error('Error fetching all certificates:', error);
        return { error: 'Failed to fetch certificates' };
    }

    // Format response with user info
    const formattedCertificates = certificates.map((cert: any) => ({
        ...cert,
        user_name: cert.profiles?.full_name || 'Unknown',
        user_email: cert.profiles?.email || '',
    }));

    return {
        success: true,
        certificates: formattedCertificates as CertificateWithUser[]
    };
}

/**
 * Generate a certificate for any user (admin only)
 */
export async function generateCertificateForUser(userId: string, courseId: string) {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        return { error: 'Not authenticated' };
    }

    // Verify admin
    const { data: profile } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    if (profile?.role !== 'admin') {
        return { error: 'Unauthorized - Admin access required' };
    }

    // Validate inputs
    if (!userId || userId.trim() === '') {
        return { error: 'Invalid user ID' };
    }

    if (!courseId || courseId.trim() === '') {
        return { error: 'Invalid course ID' };
    }

    // Check if user exists
    const { data: targetUser } = await supabase
        .from('profiles')
        .select('id, full_name')
        .eq('id', userId)
        .single();

    if (!targetUser) {
        return { error: 'User not found' };
    }

    // Check if certificate already exists
    const { data: existing } = await supabase
        .from('certificates')
        .select('*')
        .eq('user_id', userId)
        .eq('course_id', courseId)
        .single();

    if (existing) {
        return {
            success: true,
            certificate: existing as Certificate,
            message: 'Certificate already exists for this user and course'
        };
    }

    // Generate unique verification code
    const verificationCode = crypto.randomBytes(16).toString('hex');

    // Insert certificate
    const { data: certificate, error } = await supabase
        .from('certificates')
        .insert({
            user_id: userId,
            course_id: courseId,
            verification_code: verificationCode,
        })
        .select()
        .single();

    if (error) {
        console.error('Certificate generation error:', error);
        return { error: 'Failed to generate certificate' };
    }

    return {
        success: true,
        certificate: certificate as Certificate,
        message: `Certificate generated for ${targetUser.full_name}`
    };
}
