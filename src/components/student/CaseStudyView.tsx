'use client';

import { AlertTriangle, Lightbulb, MessageSquare } from 'lucide-react';

interface CaseStudyData {
    situation: string;
    reflection: string;
    learning_point: string;
}

interface CaseStudyViewProps {
    data: CaseStudyData | string; // Handle potential stringified JSON
}

export function CaseStudyView({ data }: CaseStudyViewProps) {
    let content: CaseStudyData;

    try {
        content = typeof data === 'string' ? JSON.parse(data) : data;
    } catch (e) {
        return (
            <div className="p-4 border-2 border-red-500 bg-red-50 text-red-500 rounded-lg">
                Kunne ikke laste case study data.
            </div>
        );
    }

    if (!content) return null;

    return (
        <div className="space-y-6 my-8 not-prose">
            {/* Situation Card */}
            <div className="bg-red-50 dark:bg-red-950/20 border-2 border-red-500 rounded-lg p-6 shadow-[4px_4px_0_0_#ef4444]">
                <div className="flex items-start gap-4">
                    <div className="p-2 bg-red-100 dark:bg-red-900/50 rounded-lg border-2 border-red-500 text-red-600 dark:text-red-400 shrink-0">
                        <AlertTriangle className="w-6 h-6" />
                    </div>
                    <div>
                        <h3 className="font-bold text-lg text-red-700 dark:text-red-400 mb-2">Situasjon</h3>
                        <p className="text-red-900 dark:text-red-100 leading-relaxed">
                            {content.situation}
                        </p>
                    </div>
                </div>
            </div>

            {/* Reflection Card */}
            <div className="bg-blue-50 dark:bg-blue-950/20 border-2 border-blue-500 rounded-lg p-6 ml-0 sm:ml-8 shadow-[4px_4px_0_0_#3b82f6]">
                <div className="flex items-start gap-4">
                    <div className="p-2 bg-blue-100 dark:bg-blue-900/50 rounded-lg border-2 border-blue-500 text-blue-600 dark:text-blue-400 shrink-0">
                        <MessageSquare className="w-6 h-6" />
                    </div>
                    <div>
                        <h3 className="font-bold text-lg text-blue-700 dark:text-blue-400 mb-2">Refleksjon</h3>
                        <p className="text-blue-900 dark:text-blue-100 italic leading-relaxed">
                            {content.reflection}
                        </p>
                    </div>
                </div>
            </div>

            {/* Learning Point Card */}
            <div className="bg-green-50 dark:bg-green-950/20 border-2 border-green-500 rounded-lg p-6 shadow-[4px_4px_0_0_#22c55e]">
                <div className="flex items-start gap-4">
                    <div className="p-2 bg-green-100 dark:bg-green-900/50 rounded-lg border-2 border-green-500 text-green-600 dark:text-green-400 shrink-0">
                        <Lightbulb className="w-6 h-6" />
                    </div>
                    <div>
                        <h3 className="font-bold text-lg text-green-700 dark:text-green-400 mb-2">Læringspunkt</h3>
                        <p className="text-green-900 dark:text-green-100 font-medium leading-relaxed">
                            {content.learning_point}
                        </p>
                    </div>
                </div>
            </div>
        </div>
    );
}
