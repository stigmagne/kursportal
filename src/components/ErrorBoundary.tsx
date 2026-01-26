'use client';

import React, { Component, ReactNode } from 'react';
import { AlertTriangle, RefreshCw } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { getRandomFunnyError } from '@/lib/constants/funny-messages';

interface Props {
    children: ReactNode;
    fallback?: ReactNode;
}

interface State {
    hasError: boolean;
    error: Error | null;
    funnyMessage: string;
}

export class ErrorBoundary extends Component<Props, State> {
    constructor(props: Props) {
        super(props);
        this.state = {
            hasError: false,
            error: null,
            funnyMessage: ''
        };
    }

    static getDerivedStateFromError(error: Error): Partial<State> {
        return {
            hasError: true,
            error,
            funnyMessage: getRandomFunnyError()
        };
    }

    componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
        console.error('ErrorBoundary caught an error:', error, errorInfo);
    }

    handleReset = () => {
        this.setState({
            hasError: false,
            error: null,
            funnyMessage: ''
        });
    };

    render() {
        if (this.state.hasError) {
            if (this.props.fallback) {
                return this.props.fallback;
            }

            return (
                <div className="flex flex-col items-center justify-center min-h-[400px] p-8 text-center">
                    <div className="w-16 h-16 rounded-full bg-destructive/10 flex items-center justify-center mb-4">
                        <AlertTriangle className="w-8 h-8 text-destructive" />
                    </div>
                    <h2 className="text-xl font-bold mb-2">Oi sansen!</h2>
                    <p className="text-lg text-muted-foreground mb-2 max-w-md italic">
                        "{this.state.funnyMessage}"
                    </p>
                    <p className="text-sm text-muted-foreground mb-4">
                        Prøv å laste siden på nytt eller gå tilbake.
                    </p>
                    <div className="flex gap-2">
                        <Button onClick={this.handleReset} variant="outline">
                            <RefreshCw className="w-4 h-4 mr-2" />
                            Prøv igjen
                        </Button>
                        <Button onClick={() => window.location.href = '/'}>
                            Gå til forsiden
                        </Button>
                    </div>
                    {process.env.NODE_ENV === 'development' && this.state.error && (
                        <pre className="mt-4 p-4 bg-muted text-left text-xs overflow-auto max-w-full rounded border">
                            {this.state.error.message}
                        </pre>
                    )}
                </div>
            );
        }

        return this.props.children;
    }
}

export default ErrorBoundary;
