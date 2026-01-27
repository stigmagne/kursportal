'use client';

import { useState, useEffect, useRef } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Search, X, Loader2 } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { Link } from '@/i18n/routing';

interface SearchResult {
    result_type: string;
    id: string;
    title: string;
    description: string;
    url: string;
    rank: number;
}

export function SearchBar() {
    const [query, setQuery] = useState('');
    const [results, setResults] = useState<SearchResult[]>([]);
    const [isOpen, setIsOpen] = useState(false);
    const [isLoading, setIsLoading] = useState(false);
    const searchRef = useRef<HTMLDivElement>(null);
    const inputRef = useRef<HTMLInputElement>(null);
    const supabase = createClient();
    const router = useRouter();
    const t = useTranslations('Search');

    // Debounced search
    useEffect(() => {
        if (query.length < 2) {
            setResults([]);
            setIsOpen(false);
            return;
        }

        const timer = setTimeout(() => {
            performSearch();
        }, 300);

        return () => clearTimeout(timer);
    }, [query]);

    // Click outside to close
    useEffect(() => {
        function handleClickOutside(event: MouseEvent) {
            if (searchRef.current && !searchRef.current.contains(event.target as Node)) {
                setIsOpen(false);
            }
        }

        document.addEventListener('mousedown', handleClickOutside);
        return () => document.removeEventListener('mousedown', handleClickOutside);
    }, []);

    const performSearch = async () => {
        setIsLoading(true);

        const { data, error } = await supabase
            .rpc('global_search', { search_query: query });

        if (!error && data) {
            setResults(data);
            setIsOpen(true);
        }

        setIsLoading(false);
    };

    const handleResultClick = (result: SearchResult) => {
        setIsOpen(false);
        setQuery('');
        router.push(result.url);
    };

    const handleKeyDown = (e: React.KeyboardEvent) => {
        if (e.key === 'Escape') {
            setIsOpen(false);
            inputRef.current?.blur();
        }
    };

    return (
        <div ref={searchRef} className="relative w-full max-w-md">
            {/* Search Input */}
            <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                    ref={inputRef}
                    type="text"
                    value={query}
                    onChange={(e) => setQuery(e.target.value)}
                    onKeyDown={handleKeyDown}
                    placeholder={t('placeholder')}
                    className="w-full pl-10 pr-10 py-2 bg-white border-2 border-black dark:border-white rounded-none focus:outline-none focus:ring-2 focus:ring-primary text-gray-900 dark:text-white dark:bg-gray-900 placeholder-gray-500"
                />
                {query && (
                    <button
                        onClick={() => {
                            setQuery('');
                            setResults([]);
                            setIsOpen(false);
                        }}
                        className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                    >
                        <X className="w-4 h-4" />
                    </button>
                )}
                {isLoading && (
                    <Loader2 className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-blue-500 animate-spin" />
                )}
            </div>

            {/* Search Results Dropdown */}
            {isOpen && results.length > 0 && (
                <div className="absolute top-full mt-2 w-full bg-white dark:bg-gray-900 border-2 border-black dark:border-white rounded-none shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:shadow-[4px_4px_0px_0px_rgba(255,255,255,1)] max-h-96 overflow-y-auto z-50">
                    {results.map((result) => (
                        <button
                            key={`${result.result_type}-${result.id}`}
                            onClick={() => handleResultClick(result)}
                            className="w-full text-left p-4 hover:bg-gray-50 border-b border-gray-100 last:border-b-0 transition-colors"
                        >
                            <div className="flex items-start gap-3">
                                <div className="flex-1 min-w-0">
                                    <div className="flex items-center gap-2 mb-1">
                                        <span className={`text-xs px-2 py-0.5 rounded-none font-medium border ${result.result_type === 'course'
                                            ? 'bg-blue-100 text-blue-700 border-blue-700'
                                            : 'bg-green-100 text-green-700 border-green-700'
                                            }`}>
                                            {result.result_type === 'course' ? t('course') : t('lesson')}
                                        </span>
                                    </div>
                                    <h4 className="font-medium text-gray-900 truncate">{result.title}</h4>
                                    <p className="text-sm text-gray-600 line-clamp-2 mt-1">
                                        {result.description}
                                    </p>
                                </div>
                            </div>
                        </button>
                    ))}

                    {results.length >= 20 && (
                        <div className="p-3 text-center text-sm text-gray-500 border-t border-gray-200">
                            {t('more_results')}
                        </div>
                    )}
                </div>
            )}

            {/* No Results */}
            {isOpen && !isLoading && query.length >= 2 && results.length === 0 && (
                <div className="absolute top-full mt-2 w-full bg-white dark:bg-gray-900 border-2 border-black dark:border-white rounded-none shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] p-6 text-center z-50">
                    <p className="text-gray-600">{t('no_results')}</p>
                    <p className="text-sm text-gray-500 mt-1">{t('try_different')}</p>
                </div>
            )}
        </div>
    );
}
