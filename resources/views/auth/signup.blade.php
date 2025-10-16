@extends('layouts.app')

@section('content')
    <div class="max-w-md mx-auto py-10">
        <h1 class="text-2xl font-bold mb-6">{{ __('Create your account') }}</h1>

        @if (session('status'))
            <div class="mb-4 p-4 bg-green-100 text-green-800 rounded">
                {{ session('status') }}
            </div>
        @endif

        <livewire:signup-form />
    </div>
@endsection
