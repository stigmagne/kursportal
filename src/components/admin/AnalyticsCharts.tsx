'use client';

import {
    LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
    BarChart, Bar, Legend
} from 'recharts';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

interface ActivityData {
    date: string;
    active_users: number;
    completions: number;
}

interface CourseData {
    title: string;
    enrollment_count: number;
    completion_rate: number;
}

export function AnalyticsCharts({
    activityData,
    courseData
}: {
    activityData: ActivityData[],
    courseData: CourseData[]
}) {
    return (
        <div className="grid gap-6 md:grid-cols-2">
            {/* Activity Trend */}
            <Card className="glass border-white/10 text-card-foreground">
                <CardHeader>
                    <CardTitle>Aktivitet siste 30 dager</CardTitle>
                    <CardDescription>Aktive brukere og fullføringer</CardDescription>
                </CardHeader>
                <CardContent className="h-[300px]">
                    <ResponsiveContainer width="100%" height="100%">
                        <LineChart data={activityData}>
                            <CartesianGrid strokeDasharray="3 3" opacity={0.1} />
                            <XAxis
                                dataKey="date"
                                fontSize={12}
                                tickLine={false}
                                axisLine={false}
                                tickFormatter={(value) => new Date(value).toLocaleDateString(undefined, { day: '2-digit', month: '2-digit' })}
                            />
                            <YAxis
                                fontSize={12}
                                tickLine={false}
                                axisLine={false}
                                allowDecimals={false}
                            />
                            <Tooltip
                                contentStyle={{ backgroundColor: 'rgba(0,0,0,0.8)', border: 'none', borderRadius: '8px', color: '#fff' }}
                            />
                            <Legend />
                            <Line
                                type="monotone"
                                dataKey="active_users"
                                name="Aktive Brukere"
                                stroke="#3b82f6"
                                strokeWidth={2}
                                dot={false}
                            />
                            <Line
                                type="monotone"
                                dataKey="completions"
                                name="Fullføringer"
                                stroke="#10b981"
                                strokeWidth={2}
                                dot={false}
                            />
                        </LineChart>
                    </ResponsiveContainer>
                </CardContent>
            </Card>

            {/* Course Performance */}
            <Card className="glass border-white/10 text-card-foreground">
                <CardHeader>
                    <CardTitle>Topp 5 Kurs</CardTitle>
                    <CardDescription>Innrulleringer og fullføringsgrad (%)</CardDescription>
                </CardHeader>
                <CardContent className="h-[300px]">
                    <ResponsiveContainer width="100%" height="100%">
                        <BarChart data={courseData} layout="vertical" margin={{ left: 40 }}>
                            <CartesianGrid strokeDasharray="3 3" opacity={0.1} horizontal={true} vertical={false} />
                            <XAxis type="number" hide />
                            <YAxis
                                dataKey="title"
                                type="category"
                                width={100}
                                fontSize={11}
                                tickLine={false}
                                axisLine={false}
                                tickFormatter={(value) => value.length > 15 ? value.substring(0, 15) + '...' : value}
                            />
                            <Tooltip
                                cursor={{ fill: 'rgba(255,255,255,0.05)' }}
                                contentStyle={{ backgroundColor: 'rgba(0,0,0,0.8)', border: 'none', borderRadius: '8px', color: '#fff' }}
                            />
                            <Legend />
                            <Bar dataKey="enrollment_count" name="Deltakere" fill="#f59e0b" radius={[0, 4, 4, 0]} barSize={20} />
                            <Bar dataKey="completion_rate" name="Fullført %" fill="#8b5cf6" radius={[0, 4, 4, 0]} barSize={20} />
                        </BarChart>
                    </ResponsiveContainer>
                </CardContent>
            </Card>
        </div>
    );
}
