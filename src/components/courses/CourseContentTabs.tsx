'use client';

import { useState } from 'react';
import { useTranslations } from 'next-intl';
import { BookOpen, MessageSquare } from 'lucide-react';
import { motion } from 'framer-motion';

interface CourseContentTabsProps {
    activeTab: 'content' | 'discussions';
    onTabChange: (tab: 'content' | 'discussions') => void;
    discussionCount?: number;
}

export function CourseContentTabs({ activeTab, onTabChange, discussionCount = 0 }: CourseContentTabsProps) {
    const t = useTranslations('Course');

    return (
        <div className="flex gap-4 border-b-4 border-black/10 pb-1 mb-8 overflow-x-auto">
            <button
                onClick={() => onTabChange('content')}
                className={`
                    relative flex items-center justify-center gap-2 px-6 py-3 font-black uppercase tracking-wide text-sm border-b-4 transition-all whitespace-nowrap
                    ${activeTab === 'content'
                        ? 'border-black text-black translate-y-1'
                        : 'border-transparent text-gray-400 hover:text-gray-600 hover:border-gray-200'
                    }
                `}
            >
                <BookOpen className="w-4 h-4" />
                {t('content')}
            </button>

            <button
                onClick={() => onTabChange('discussions')}
                className={`
                    relative flex items-center justify-center gap-2 px-6 py-3 font-black uppercase tracking-wide text-sm border-b-4 transition-all whitespace-nowrap
                    ${activeTab === 'discussions'
                        ? 'border-black text-black translate-y-1'
                        : 'border-transparent text-gray-400 hover:text-gray-600 hover:border-gray-200'
                    }
                `}
            >
                <MessageSquare className="w-4 h-4" />
                {t('discussions')}
                {discussionCount > 0 && (
                    <span className={`
                        px-2 py-0.5 rounded-full text-xs font-bold border-2 border-black
                        ${activeTab === 'discussions' ? 'bg-black text-white' : 'bg-gray-200 text-gray-500'}
                    `}>
                        {discussionCount}
                    </span>
                )}
            </button>
        </div>
    );
}
