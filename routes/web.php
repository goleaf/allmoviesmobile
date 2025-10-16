<?php

use Illuminate\Support\Facades\Route;

Route::middleware('guest')->group(function () {
    Route::view('/signup', 'auth.signup')->name('signup');
});

Route::get('/', function () {
    return view('welcome');
})->name('home');
