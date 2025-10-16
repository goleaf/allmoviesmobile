<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ config('app.name', 'Laravel Stub') }}</title>
    @livewireStyles
</head>
<body class="antialiased bg-gray-100">
    <main class="min-h-screen">
        @yield('content')
    </main>

    @livewireScripts
</body>
</html>
