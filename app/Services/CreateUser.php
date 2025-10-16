<?php

namespace App\Services;

use App\Mail\WelcomeMail;
use App\Models\User;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

class CreateUser
{
    /**
     * Persist a new user and queue a welcome message.
     *
     * @param  array{name: string, email: string, password: string}  $payload
     */
    public function handle(array $payload): Authenticatable
    {
        $user = User::create([
            'name' => $payload['name'],
            'email' => $payload['email'],
            'password' => Hash::make($payload['password']),
        ]);

        Mail::to($user)->queue(new WelcomeMail($user));

        return $user;
    }
}
