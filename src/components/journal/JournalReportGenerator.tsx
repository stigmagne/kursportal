'use client';

import { useState } from 'react';
import { Document, Page, Text, View, StyleSheet, pdf } from '@react-pdf/renderer';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { FileDown, Loader2, Check } from 'lucide-react';
import { useTranslations } from 'next-intl';

interface JournalEntry {
    id: string;
    date: string;
    content: string;
}

interface AssessmentEntry {
    id: string;
    date: string;
    templateTitle: string;
    responses: Record<string, any>;
    questions: Array<{ id: string; text: string; type: string }>;
}

interface JournalReportGeneratorProps {
    entries: JournalEntry[];
    assessments: AssessmentEntry[];
    selectedEntryIds: Set<string>;
    selectedAssessmentIds: Set<string>;
    onToggleEntry: (id: string) => void;
    onToggleAssessment: (id: string) => void;
    onSelectAll: () => void;
    onDeselectAll: () => void;
}

// PDF Styles
const styles = StyleSheet.create({
    page: {
        padding: 40,
        fontFamily: 'Helvetica',
    },
    header: {
        marginBottom: 30,
        borderBottom: '2px solid #000',
        paddingBottom: 20,
    },
    title: {
        fontSize: 24,
        fontWeight: 'bold',
        marginBottom: 5,
    },
    subtitle: {
        fontSize: 12,
        color: '#666',
    },
    section: {
        marginTop: 20,
        marginBottom: 10,
    },
    sectionTitle: {
        fontSize: 16,
        fontWeight: 'bold',
        marginBottom: 10,
        backgroundColor: '#f0f0f0',
        padding: 8,
    },
    entry: {
        marginBottom: 15,
        padding: 10,
        border: '1px solid #ccc',
    },
    entryDate: {
        fontSize: 10,
        color: '#666',
        marginBottom: 5,
    },
    entryContent: {
        fontSize: 11,
        lineHeight: 1.5,
    },
    assessmentQuestion: {
        fontSize: 10,
        fontWeight: 'bold',
        marginTop: 5,
    },
    assessmentAnswer: {
        fontSize: 10,
        marginLeft: 10,
        color: '#333',
    },
    footer: {
        position: 'absolute',
        bottom: 30,
        left: 40,
        right: 40,
        textAlign: 'center',
        fontSize: 8,
        color: '#999',
    },
});

// PDF Document Component
const JournalPDF = ({ entries, assessments }: { entries: JournalEntry[], assessments: AssessmentEntry[] }) => (
    <Document>
        <Page size="A4" style={styles.page}>
            <View style={styles.header}>
                <Text style={styles.title}>Min Journal</Text>
                <Text style={styles.subtitle}>
                    Eksportert {new Date().toLocaleDateString('no-NO')}
                </Text>
            </View>

            {entries.length > 0 && (
                <View style={styles.section}>
                    <Text style={styles.sectionTitle}>Dagbok-innlegg ({entries.length})</Text>
                    {entries.map((entry, index) => (
                        <View key={entry.id} style={styles.entry}>
                            <Text style={styles.entryDate}>
                                {new Date(entry.date).toLocaleDateString('no-NO')} kl. {new Date(entry.date).toLocaleTimeString('no-NO')}
                            </Text>
                            <Text style={styles.entryContent}>{entry.content}</Text>
                        </View>
                    ))}
                </View>
            )}

            {assessments.length > 0 && (
                <View style={styles.section}>
                    <Text style={styles.sectionTitle}>Vurderinger ({assessments.length})</Text>
                    {assessments.map((assessment) => (
                        <View key={assessment.id} style={styles.entry}>
                            <Text style={styles.entryDate}>
                                {assessment.templateTitle} - {new Date(assessment.date).toLocaleDateString('no-NO')}
                            </Text>
                            {assessment.questions.map((q) => (
                                <View key={q.id}>
                                    <Text style={styles.assessmentQuestion}>{q.text}</Text>
                                    <Text style={styles.assessmentAnswer}>
                                        {assessment.responses[q.id] !== undefined
                                            ? (q.type === 'scale' ? `${assessment.responses[q.id]}/10` : assessment.responses[q.id])
                                            : 'Ikke besvart'}
                                    </Text>
                                </View>
                            ))}
                        </View>
                    ))}
                </View>
            )}

            <Text style={styles.footer}>
                Denne rapporten inneholder sensitiv informasjon. Håndter med varsomhet.
            </Text>
        </Page>
    </Document>
);

export default function JournalReportGenerator({
    entries,
    assessments,
    selectedEntryIds,
    selectedAssessmentIds,
    onToggleEntry,
    onToggleAssessment,
    onSelectAll,
    onDeselectAll,
}: JournalReportGeneratorProps) {
    const t = useTranslations('Journal');
    const [isGenerating, setIsGenerating] = useState(false);

    const handleExportPDF = async () => {
        setIsGenerating(true);
        try {
            const selectedEntries = entries.filter(e => selectedEntryIds.has(e.id));
            const selectedAssessmentsList = assessments.filter(a => selectedAssessmentIds.has(a.id));

            const blob = await pdf(
                <JournalPDF entries={selectedEntries} assessments={selectedAssessmentsList} />
            ).toBlob();

            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `journal-rapport-${new Date().toISOString().split('T')[0]}.pdf`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        } catch (err) {
            console.error('PDF generation failed:', err);
            alert(t('pdf_failed') || 'Kunne ikke generere PDF');
        } finally {
            setIsGenerating(false);
        }
    };

    const handleExportJSON = () => {
        const selectedEntries = entries.filter(e => selectedEntryIds.has(e.id));
        const selectedAssessmentsList = assessments.filter(a => selectedAssessmentIds.has(a.id));

        const exportData = {
            exportedAt: new Date().toISOString(),
            entries: selectedEntries,
            assessments: selectedAssessmentsList,
        };

        const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `journal-export-${new Date().toISOString().split('T')[0]}.json`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    };

    const totalSelected = selectedEntryIds.size + selectedAssessmentIds.size;

    return (
        <Card>
            <CardHeader>
                <CardTitle className="flex items-center gap-2">
                    <FileDown className="w-5 h-5" />
                    {t('export_report') || 'Eksporter rapport'}
                </CardTitle>
                <CardDescription>
                    {t('export_description') || 'Velg innlegg og vurderinger du vil inkludere i rapporten.'}
                </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
                {/* Selection Controls */}
                <div className="flex gap-2 mb-4">
                    <Button variant="outline" size="sm" onClick={onSelectAll}>
                        {t('select_all') || 'Velg alle'}
                    </Button>
                    <Button variant="outline" size="sm" onClick={onDeselectAll}>
                        {t('deselect_all') || 'Fjern valg'}
                    </Button>
                </div>

                {/* Entry Selection */}
                {entries.length > 0 && (
                    <div className="space-y-2">
                        <h4 className="font-medium text-sm">{t('journal_entries') || 'Dagbok-innlegg'}</h4>
                        <div className="max-h-40 overflow-y-auto space-y-1 border-2 border-black dark:border-white p-2">
                            {entries.map(entry => (
                                <label
                                    key={entry.id}
                                    className="flex items-center gap-2 cursor-pointer hover:bg-muted p-1"
                                >
                                    <input
                                        type="checkbox"
                                        checked={selectedEntryIds.has(entry.id)}
                                        onChange={() => onToggleEntry(entry.id)}
                                        className="w-4 h-4"
                                    />
                                    <span className="text-sm">
                                        {new Date(entry.date).toLocaleDateString()} - {entry.content.substring(0, 50)}...
                                    </span>
                                </label>
                            ))}
                        </div>
                    </div>
                )}

                {/* Assessment Selection */}
                {assessments.length > 0 && (
                    <div className="space-y-2">
                        <h4 className="font-medium text-sm">{t('assessments') || 'Vurderinger'}</h4>
                        <div className="max-h-40 overflow-y-auto space-y-1 border-2 border-black dark:border-white p-2">
                            {assessments.map(assessment => (
                                <label
                                    key={assessment.id}
                                    className="flex items-center gap-2 cursor-pointer hover:bg-muted p-1"
                                >
                                    <input
                                        type="checkbox"
                                        checked={selectedAssessmentIds.has(assessment.id)}
                                        onChange={() => onToggleAssessment(assessment.id)}
                                        className="w-4 h-4"
                                    />
                                    <span className="text-sm">
                                        {assessment.templateTitle} - {new Date(assessment.date).toLocaleDateString()}
                                    </span>
                                </label>
                            ))}
                        </div>
                    </div>
                )}

                {/* Export Buttons */}
                <div className="flex gap-3 pt-4 border-t">
                    <Button
                        onClick={handleExportPDF}
                        disabled={totalSelected === 0 || isGenerating}
                    >
                        {isGenerating ? (
                            <>
                                <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                                {t('generating') || 'Genererer...'}
                            </>
                        ) : (
                            <>
                                <FileDown className="w-4 h-4 mr-2" />
                                {t('export_pdf') || 'Last ned PDF'} ({totalSelected})
                            </>
                        )}
                    </Button>
                    <Button
                        variant="outline"
                        onClick={handleExportJSON}
                        disabled={totalSelected === 0}
                    >
                        {t('export_json') || 'Last ned JSON'}
                    </Button>
                </div>
            </CardContent>
        </Card>
    );
}
