<?php

namespace App\Livewire;

use App\Services\CreateUser;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Session;
use Livewire\Component;

class SignupForm extends Component
{
    /**
     * The registrant's display name.
     *
     * @var string
     */
    public string $name = '';

    /**
     * The registrant's e-mail address.
     *
     * @var string
     */
    public string $email = '';

    /**
     * The registrant's password.
     *
     * @var string
     */
    public string $password = '';

    /**
     * Validation rules for the registration form.
     *
     * @var array<string, mixed>
     */
    protected array $rules = [
        'name' => ['required', 'string', 'max:255'],
        'email' => ['required', 'email', 'max:255', 'unique:users,email'],
        'password' => ['required', 'string', 'min:8'],
    ];

    /**
     * Persist the new user and redirect the visitor.
     */
    public function submit(CreateUser $creator)
    {
        $data = $this->validate();

        $user = $creator->handle($data);

        Auth::login($user);

        Session::flash('status', __('Registration successful!'));

        return redirect()->intended('/');
    }

    public function render()
    {
        return view('livewire.signup-form');
    }
}
