<div>
    <form wire:submit.prevent="submit" class="space-y-4">
        @csrf
        <div>
            <label for="name" class="block text-sm font-medium text-gray-700">{{ __('Name') }}</label>
            <input wire:model.defer="name" id="name" type="text" class="mt-1 block w-full border rounded p-2" autocomplete="name">
            @error('name')
                <p class="text-red-600 text-sm">{{ $message }}</p>
            @enderror
        </div>

        <div>
            <label for="email" class="block text-sm font-medium text-gray-700">{{ __('Email') }}</label>
            <input wire:model.defer="email" id="email" type="email" class="mt-1 block w-full border rounded p-2" autocomplete="email">
            @error('email')
                <p class="text-red-600 text-sm">{{ $message }}</p>
            @enderror
        </div>

        <div>
            <label for="password" class="block text-sm font-medium text-gray-700">{{ __('Password') }}</label>
            <input wire:model.defer="password" id="password" type="password" class="mt-1 block w-full border rounded p-2" autocomplete="new-password">
            @error('password')
                <p class="text-red-600 text-sm">{{ $message }}</p>
            @enderror
        </div>

        <div>
            <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded">{{ __('Create account') }}</button>
        </div>
    </form>
</div>
