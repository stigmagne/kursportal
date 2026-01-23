'use client';

import { jsPDF } from 'jspdf';

interface CertificateData {
    studentName: string;
    courseTitle: string;
    completionDate: string;
    certificateNumber: string;
}

export function generateCertificatePDF(data: CertificateData) {
    const { studentName, courseTitle, completionDate, certificateNumber } = data;

    // Create PDF in landscape A4 format
    const pdf = new jsPDF({
        orientation: 'landscape',
        unit: 'mm',
        format: 'a4'
    });

    const pageWidth = pdf.internal.pageSize.getWidth();
    const pageHeight = pdf.internal.pageSize.getHeight();

    // Background - elegant border
    pdf.setDrawColor(41, 128, 185); // Professional blue
    pdf.setLineWidth(2);
    pdf.rect(10, 10, pageWidth - 20, pageHeight - 20);

    pdf.setLineWidth(0.5);
    pdf.rect(15, 15, pageWidth - 30, pageHeight - 30);

    // Decorative corners
    pdf.setFillColor(41, 128, 185);
    const cornerSize = 5;
    // Top left
    pdf.triangle(15, 15, 15 + cornerSize, 15, 15, 15 + cornerSize, 'F');
    // Top right
    pdf.triangle(pageWidth - 15, 15, pageWidth - 15 - cornerSize, 15, pageWidth - 15, 15 + cornerSize, 'F');
    // Bottom left
    pdf.triangle(15, pageHeight - 15, 15 + cornerSize, pageHeight - 15, 15, pageHeight - 15 - cornerSize, 'F');
    // Bottom right
    pdf.triangle(pageWidth - 15, pageHeight - 15, pageWidth - 15 - cornerSize, pageHeight - 15, pageWidth - 15, pageHeight - 15 - cornerSize, 'F');

    // Title
    pdf.setFontSize(32);
    pdf.setFont('helvetica', 'bold');
    pdf.setTextColor(41, 128, 185);
    pdf.text('CERTIFICATE OF COMPLETION', pageWidth / 2, 40, { align: 'center' });

    // Decorative line under title
    pdf.setDrawColor(41, 128, 185);
    pdf.setLineWidth(1);
    const lineY = 45;
    pdf.line(pageWidth / 2 - 40, lineY, pageWidth / 2 + 40, lineY);

    // "This certifies that"
    pdf.setFontSize(14);
    pdf.setFont('helvetica', 'normal');
    pdf.setTextColor(80, 80, 80);
    pdf.text('This certifies that', pageWidth / 2, 60, { align: 'center' });

    // Student Name
    pdf.setFontSize(28);
    pdf.setFont('helvetica', 'bold');
    pdf.setTextColor(0, 0, 0);
    pdf.text(studentName, pageWidth / 2, 75, { align: 'center' });

    // Underline student name
    const nameWidth = pdf.getTextWidth(studentName);
    pdf.setDrawColor(0, 0, 0);
    pdf.setLineWidth(0.5);
    pdf.line(pageWidth / 2 - nameWidth / 2, 77, pageWidth / 2 + nameWidth / 2, 77);

    // "has successfully completed"
    pdf.setFontSize(14);
    pdf.setFont('helvetica', 'normal');
    pdf.setTextColor(80, 80, 80);
    pdf.text('has successfully completed', pageWidth / 2, 90, { align: 'center' });

    // Course Title
    pdf.setFontSize(22);
    pdf.setFont('helvetica', 'bold');
    pdf.setTextColor(41, 128, 185);

    // Handle long course titles with word wrapping
    const maxWidth = pageWidth - 80;
    const lines = pdf.splitTextToSize(courseTitle, maxWidth);
    const courseY = 105;
    pdf.text(lines, pageWidth / 2, courseY, { align: 'center' });

    // Completion Date
    pdf.setFontSize(12);
    pdf.setFont('helvetica', 'normal');
    pdf.setTextColor(80, 80, 80);
    const dateY = courseY + (lines.length * 8) + 15;
    pdf.text(`Completion Date: ${completionDate}`, pageWidth / 2, dateY, { align: 'center' });

    // Certificate Number
    pdf.setFontSize(10);
    pdf.setTextColor(100, 100, 100);
    pdf.text(`Certificate No: ${certificateNumber}`, pageWidth / 2, dateY + 10, { align: 'center' });

    // Footer - Organization name
    pdf.setFontSize(14);
    pdf.setFont('helvetica', 'bold');
    pdf.setTextColor(41, 128, 185);
    pdf.text('En Helt Syk Oppvekst', pageWidth / 2, pageHeight - 30, { align: 'center' });

    // Signature line (placeholder)
    pdf.setDrawColor(0, 0, 0);
    pdf.setLineWidth(0.5);
    const sigLineY = pageHeight - 40;
    pdf.line(pageWidth / 2 - 40, sigLineY, pageWidth / 2 + 40, sigLineY);

    pdf.setFontSize(10);
    pdf.setFont('helvetica', 'normal');
    pdf.setTextColor(80, 80, 80);
    pdf.text('Authorized Signature', pageWidth / 2, sigLineY + 5, { align: 'center' });

    return pdf;
}

export function downloadCertificate(data: CertificateData) {
    const pdf = generateCertificatePDF(data);
    const filename = `Certificate_${data.courseTitle.replace(/[^a-zA-Z0-9]/g, '_')}_${data.certificateNumber}.pdf`;
    pdf.save(filename);
}

export function previewCertificate(data: CertificateData): string {
    const pdf = generateCertificatePDF(data);
    return pdf.output('dataurlstring');
}
