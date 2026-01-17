#!/bin/bash
set -e

REMOTE="/var/www/pterodactyl/app/Http/Controllers/Admin/Settings/IndexController.php"
TS=$(date +"%Y%m%d_%H%M%S")
BACKUP="${REMOTE}.bak_${TS}"

echo "🚀 INSTALL PROTECT SETTINGS (SAFE)"

if [ ! -f "$REMOTE" ]; then
  echo "❌ IndexController.php TIDAK DITEMUKAN"
  exit 1
fi

cp "$REMOTE" "$BACKUP"
echo "📦 Backup: $BACKUP"

cat > "$REMOTE" << 'PHP'
<?php

namespace Pterodactyl\Http\Controllers\Admin\Settings;

use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;
use Prologue\Alerts\AlertsMessageBag;
use Illuminate\Contracts\Console\Kernel;
use Illuminate\View\Factory as ViewFactory;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Traits\Helpers\AvailableLanguages;
use Pterodactyl\Services\Helpers\SoftwareVersionService;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\Http\Requests\Admin\Settings\BaseSettingsFormRequest;

class IndexController extends Controller
{
    use AvailableLanguages;

    public function __construct(
        private AlertsMessageBag $alert,
        private Kernel $kernel,
        private SettingsRepositoryInterface $settings,
        private SoftwareVersionService $versionService,
        private ViewFactory $view
    ) {}

    public function index(): View
    {
        $user = Auth::user();
        if (!$user || (int)$user->id !== 1) {
            return response()->view('errors.403', [], 403);
        }

        return $this->view->make('admin.settings.index', [
            'version' => $this->versionService,
            'languages' => $this->getAvailableLanguages(true),
        ]);
    }

    public function update(BaseSettingsFormRequest $request): RedirectResponse
    {
        $user = Auth::user();
        if (!$user || (int)$user->id !== 1) {
            return response()->view('errors.403', [], 403);
        }

        foreach ($request->normalize() as $key => $value) {
            $this->settings->set('settings::' . $key, $value);
        }

        $this->kernel->call('queue:restart');
        $this->alert->success('Settings updated')->flash();

        return redirect()->route('admin.settings');
    }
}
PHP

php artisan optimize:clear

echo "✅ PROTECT SETTINGS AKTIF (ONLY ID 1)"
