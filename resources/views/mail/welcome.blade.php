@php($userName = $user->name ?? __('there'))

<p>{{ __('Hi :name,', ['name' => $userName]) }}</p>

<p>{{ __('Thanks for joining our community! We are excited to have you on board.') }}</p>

<p>{{ __('You can now explore all the features available to registered members.') }}</p>

<p>{{ __('Cheers,') }}<br>{{ config('app.name', 'Our Application') }}</p>
