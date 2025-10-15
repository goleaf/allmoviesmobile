<?php

namespace Tests\Feature\Auth;

use App\Livewire\SignupForm;
use App\Mail\WelcomeMail;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Livewire\Livewire;
use Tests\TestCase;

class SignupTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_can_view_signup_form(): void
    {
        $this->get(route('signup'))
            ->assertOk()
            ->assertSeeLivewire(SignupForm::class);
    }

    public function test_validation_errors_are_shown(): void
    {
        Livewire::test(SignupForm::class)
            ->set('name', '')
            ->set('email', 'invalid-email')
            ->set('password', 'short')
            ->call('submit')
            ->assertHasErrors([
                'name' => 'required',
                'email' => 'email',
                'password' => 'min',
            ]);
    }

    public function test_successful_registration_creates_user_and_sends_mail(): void
    {
        Mail::fake();

        Livewire::test(SignupForm::class)
            ->set('name', 'Jane Doe')
            ->set('email', 'jane@example.com')
            ->set('password', 'secret123')
            ->call('submit')
            ->assertRedirect('/');

        $this->assertDatabaseHas('users', [
            'email' => 'jane@example.com',
        ]);

        $user = User::whereEmail('jane@example.com')->firstOrFail();
        $this->assertTrue(Hash::check('secret123', $user->password));

        Mail::assertQueued(WelcomeMail::class, function (WelcomeMail $mail) use ($user) {
            return $mail->hasTo($user->email);
        });
    }

    public function test_authenticated_users_are_redirected_away_from_signup(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(route('signup'))
            ->assertRedirect('/');
    }
}
