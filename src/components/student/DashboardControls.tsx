'use client';

import { useState, useMemo } from 'react';
import { Search } from 'lucide-react';

interface DashboardControlsProps {
    courses: any[];
    onFilteredCoursesChange: (filtered: any[]) => void;
}

export default function DashboardControls({ courses, onFilteredCoursesChange }: DashboardControlsProps) {
    const [searchQuery, setSearchQuery] = useState('');
    const [filterTab, setFilterTab] = useState<'all' | 'in-progress' | 'completed'>('all');
    const [sortBy, setSortBy] = useState<'recent' | 'progress' | 'name'>('recent');

    // Apply filters and sorting
    const filteredAndSortedCourses = useMemo(() => {
        let filtered = [...courses];

        // Filter by search query
        if (searchQuery) {
            filtered = filtered.filter(c =>
                c.course.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                c.course.description?.toLowerCase().includes(searchQuery.toLowerCase())
            );
        }

        // Filter by status
        if (filterTab === 'in-progress') {
            filtered = filtered.filter(c => c.progress > 0 && c.progress < 100);
        } else if (filterTab === 'completed') {
            filtered = filtered.filter(c => c.progress >= 100);
        }

        // Sort
        filtered.sort((a, b) => {
            if (sortBy === 'progress') {
                return b.progress - a.progress; // Highest progress first
            } else if (sortBy === 'name') {
                return a.course.title.localeCompare(b.course.title);
            } else {
                // Sort by enrollment date (most recent first)
                return new Date(b.created_at).getTime() - new Date(a.created_at).getTime();
            }
        });

        return filtered;
    }, [courses, searchQuery, filterTab, sortBy]);

    // Update parent whenever filtered courses change
    useState(() => {
        onFilteredCoursesChange(filteredAndSortedCourses);
    });

    return (
        <div className="space-y-4 mb-8">
            {/* Search Bar */}
            <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
                <input
                    type="text"
                    placeholder="Search courses..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full pl-10 pr-4 py-3 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary"
                />
            </div>

            {/* Filter Tabs and Sort */}
            <div className="flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center">
                {/* Filter Tabs */}
                <div className="flex gap-2">
                    <button
                        onClick={() => setFilterTab('all')}
                        className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${filterTab === 'all'
                                ? 'bg-primary text-primary-foreground'
                                : 'bg-muted hover:bg-muted/80'
                            }`}
                    >
                        All ({courses.length})
                    </button>
                    <button
                        onClick={() => setFilterTab('in-progress')}
                        className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${filterTab === 'in-progress'
                                ? 'bg-primary text-primary-foreground'
                                : 'bg-muted hover:bg-muted/80'
                            }`}
                    >
                        In Progress ({courses.filter(c => c.progress > 0 && c.progress < 100).length})
                    </button>
                    <button
                        onClick={() => setFilterTab('completed')}
                        className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${filterTab === 'completed'
                                ? 'bg-primary text-primary-foreground'
                                : 'bg-muted hover:bg-muted/80'
                            }`}
                    >
                        Completed ({courses.filter(c => c.progress >= 100).length})
                    </button>
                </div>

                {/* Sort Dropdown */}
                <select
                    value={sortBy}
                    onChange={(e) => setSortBy(e.target.value as any)}
                    className="px-4 py-2 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary text-sm"
                >
                    <option value="recent">Recently Enrolled</option>
                    <option value="progress">Progress</option>
                    <option value="name">Name (A-Z)</option>
                </select>
            </div>

            {/* Results count */}
            {searchQuery && (
                <p className="text-sm text-muted-foreground">
                    Found {filteredAndSortedCourses.length} course{filteredAndSortedCourses.length !== 1 ? 's' : ''}
                </p>
            )}
        </div>
    );
}
