
export type QuestionType = 'single' | 'multiple';

export interface Option {
    id: string;
    text: string;
}

export interface Question {
    id: string;
    text: string;
    type: QuestionType;
    options: Option[];
    correctOptionIds: string[]; // Only visible to admin/server
    explanation?: string; // Explanation shown after quiz completion
}

export interface Quiz {
    id?: string;
    title: string;
    description?: string;
    questions: Question[];
    time_limit?: number; // Time limit in minutes
    randomize_questions?: boolean;
    show_explanations?: boolean;
}
