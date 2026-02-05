'use client';

import { useEffect, useState } from 'react';
import { useTranslations } from 'next-intl';
import { Bug, ChevronDown, ChevronUp, Loader2 } from 'lucide-react';
import { getAllBugReports, updateBugReportStatus } from '@/app/actions/bug-report-actions';

interface BugReport {
    id: string;
    user_id: string | null;
    email: string | null;
    full_name: string | null;
    title: string;
    description: string;
    page_url: string | null;
    browser_info: string | null;
    status: 'open' | 'in-progress' | 'resolved' | 'closed';
    priority: 'low' | 'medium' | 'high' | 'critical';
    admin_notes: string | null;
    created_at: string;
    updated_at: string;
}

export default function BugReportsPage() {
    const t = useTranslations('AdminBugReports');
    const [reports, setReports] = useState<BugReport[]>([]);
    const [loading, setLoading] = useState(true);
    const [expandedId, setExpandedId] = useState<string | null>(null);
    const [filterStatus, setFilterStatus] = useState<string>('all');

    useEffect(() => {
        loadReports();
    }, []);

    const loadReports = async () => {
        setLoading(true);
        const result = await getAllBugReports();

        if (result.data) {
            setReports(result.data);
        }
        setLoading(false);
    };

    const handleStatusUpdate = async (
        reportId: string,
        status: 'open' | 'in-progress' | 'resolved' | 'closed',
        priority?: 'low' | 'medium' | 'high' | 'critical',
        adminNotes?: string
    ) => {
        await updateBugReportStatus(reportId, status, priority, adminNotes);
        await loadReports();
    };

    const filteredReports = filterStatus === 'all'
        ? reports
        : reports.filter(r => r.status === filterStatus);

    const getStatusBadge = (status: string) => {
        const colors: Record<string, string> = {
            open: 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-200 border-yellow-500',
            'in-progress': 'bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-200 border-blue-500',
            resolved: 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-200 border-green-500',
            closed: 'bg-gray-100 dark:bg-gray-900/30 text-gray-800 dark:text-gray-200 border-gray-500',
        };
        return colors[status] || colors.open;
    };

    const getPriorityBadge = (priority: string) => {
        const colors: Record<string, string> = {
            low: 'bg-gray-100 dark:bg-gray-900/30 text-gray-800 dark:text-gray-200 border-gray-400',
            medium: 'bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-200 border-blue-500',
            high: 'bg-orange-100 dark:bg-orange-900/30 text-orange-800 dark:text-orange-200 border-orange-500',
            critical: 'bg-red-100 dark:bg-red-900/30 text-red-800 dark:text-red-200 border-red-500',
        };
        return colors[priority] || colors.medium;
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center min-h-[400px]">
                <Loader2 className="w-8 h-8 animate-spin" />
            </div>
        );
    }

    return (
        <div className="p-6 space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                    <Bug className="w-8 h-8" />
                    <h1 className="text-3xl font-black">{t('title')}</h1>
                </div>
                <div className="flex items-center gap-2">
                    <span className="text-sm font-bold">{t('filter')}:</span>
                    <select
                        value={filterStatus}
                        onChange={(e) => setFilterStatus(e.target.value)}
                        className="px-3 py-2 border-3 border-black dark:border-white bg-white dark:bg-gray-800 font-bold"
                    >
                        <option value="all">{t('filterAll')}</option>
                        <option value="open">{t('status.open')}</option>
                        <option value="in-progress">{t('status.in-progress')}</option>
                        <option value="resolved">{t('status.resolved')}</option>
                        <option value="closed">{t('status.closed')}</option>
                    </select>
                </div>
            </div>

            {/* Reports List */}
            <div className="space-y-4">
                {filteredReports.length === 0 ? (
                    <div className="p-8 text-center border-3 border-black dark:border-white bg-gray-50 dark:bg-gray-900">
                        <Bug className="w-12 h-12 mx-auto mb-4 opacity-50" />
                        <p className="text-gray-600 dark:text-gray-400">{t('noReports')}</p>
                    </div>
                ) : (
                    filteredReports.map((report) => (
                        <div
                            key={report.id}
                            className="border-3 border-black dark:border-white bg-white dark:bg-gray-900 shadow-hard"
                        >
                            {/* Report Header (Always Visible) */}
                            <button
                                onClick={() => setExpandedId(expandedId === report.id ? null : report.id)}
                                className="w-full p-4 flex items-start justify-between hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors text-left"
                            >
                                <div className="flex-1 space-y-2">
                                    <div className="flex items-center gap-3 flex-wrap">
                                        <h3 className="font-bold text-lg">{report.title}</h3>
                                        <span className={`px-3 py-1 text-xs font-bold border-2 ${getStatusBadge(report.status)}`}>
                                            {t(`status.${report.status}`)}
                                        </span>
                                        <span className={`px-3 py-1 text-xs font-bold border-2 ${getPriorityBadge(report.priority)}`}>
                                            {t(`priority.${report.priority}`)}
                                        </span>
                                    </div>
                                    <div className="text-sm text-gray-600 dark:text-gray-400">
                                        {report.full_name || report.email} • {new Date(report.created_at).toLocaleDateString()}
                                    </div>
                                </div>
                                {expandedId === report.id ? <ChevronUp /> : <ChevronDown />}
                            </button>

                            {/* Expanded Details */}
                            {expandedId === report.id && (
                                <div className="border-t-3 border-black dark:border-white p-4 space-y-4">
                                    {/* Description */}
                                    <div>
                                        <label className="block text-sm font-bold mb-1">{t('descriptionLabel')}</label>
                                        <p className="text-sm whitespace-pre-wrap bg-gray-50 dark:bg-gray-800 p-3 border-2 border-gray-300 dark:border-gray-700">
                                            {report.description}
                                        </p>
                                    </div>

                                    {/* Page URL */}
                                    {report.page_url && (
                                        <div>
                                            <label className="block text-sm font-bold mb-1">{t('pageUrl')}</label>
                                            <a
                                                href={report.page_url}
                                                target="_blank"
                                                rel="noopener noreferrer"
                                                className="text-sm text-primary underline break-all"
                                            >
                                                {report.page_url}
                                            </a>
                                        </div>
                                    )}

                                    {/* Browser Info */}
                                    {report.browser_info && (
                                        <div>
                                            <label className="block text-sm font-bold mb-1">{t('browserInfo')}</label>
                                            <p className="text-xs text-gray-600 dark:text-gray-400 bg-gray-50 dark:bg-gray-800 p-2 border-2 border-gray-300 dark:border-gray-700 font-mono break-all">
                                                {report.browser_info}
                                            </p>
                                        </div>
                                    )}

                                    {/* Admin Controls */}
                                    <div className="grid grid-cols-2 gap-4 pt-4 border-t-2 border-gray-300 dark:border-gray-700">
                                        <div>
                                            <label className="block text-sm font-bold mb-2">{t('updateStatus')}</label>
                                            <select
                                                value={report.status}
                                                onChange={(e) =>
                                                    handleStatusUpdate(
                                                        report.id,
                                                        e.target.value as any,
                                                        report.priority
                                                    )
                                                }
                                                className="w-full px-3 py-2 border-3 border-black dark:border-white bg-white dark:bg-gray-800 font-bold"
                                            >
                                                <option value="open">{t('status.open')}</option>
                                                <option value="in-progress">{t('status.in-progress')}</option>
                                                <option value="resolved">{t('status.resolved')}</option>
                                                <option value="closed">{t('status.closed')}</option>
                                            </select>
                                        </div>

                                        <div>
                                            <label className="block text-sm font-bold mb-2">{t('updatePriority')}</label>
                                            <select
                                                value={report.priority}
                                                onChange={(e) =>
                                                    handleStatusUpdate(
                                                        report.id,
                                                        report.status,
                                                        e.target.value as any
                                                    )
                                                }
                                                className="w-full px-3 py-2 border-3 border-black dark:border-white bg-white dark:bg-gray-800 font-bold"
                                            >
                                                <option value="low">{t('priority.low')}</option>
                                                <option value="medium">{t('priority.medium')}</option>
                                                <option value="high">{t('priority.high')}</option>
                                                <option value="critical">{t('priority.critical')}</option>
                                            </select>
                                        </div>
                                    </div>

                                    {/* Admin Notes */}
                                    <div>
                                        <label className="block text-sm font-bold mb-2">{t('adminNotes')}</label>
                                        <textarea
                                            defaultValue={report.admin_notes || ''}
                                            onBlur={(e) =>
                                                handleStatusUpdate(
                                                    report.id,
                                                    report.status,
                                                    report.priority,
                                                    e.target.value
                                                )
                                            }
                                            placeholder={t('adminNotesPlaceholder')}
                                            className="w-full p-3 border-3 border-black dark:border-white bg-white dark:bg-gray-800 min-h-[100px]"
                                        />
                                    </div>
                                </div>
                            )}
                        </div>
                    ))
                )}
            </div>
        </div>
    );
}
