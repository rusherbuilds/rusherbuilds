# أوامر نشر RUSHERBUILDS على GitHub

الهدف: مستودع **عام** بالاسم المطابق للحساب `rusherbuilds/rusherbuilds`. ظهور ملف `README.md` على البروفايل مشروط بأن يكون في جذر المستودع العام.

## Windows 11 — PowerShell (الطريقة الموصى بها)

1. ثبّت Git وGitHub CLI إذا لم يكونا موجودين. افتح PowerShell جديدًا بعد التثبيت:

```powershell
winget install --id Git.Git -e
winget install --id GitHub.cli -e
```

2. فك ضغط الحزمة الجديدة، ثم افتح PowerShell في **المجلد الذي يحتوي README.md**. أو استخدم `cd` مع مسارك الحقيقي:

```powershell
cd "C:\PATH\TO\RUSHERBUILDS_PROFILE_ENHANCED"
gh auth login -h github.com
gh auth setup-git
gh api user --jq .login
```

**تحقق من الناتج:** يجب أن يظهر `rusherbuilds`. لو ظهر حساب آخر، استعمل `gh auth switch -h github.com` واختر حسابك الصحيح.

3. اعمل معاينة بدون إنشاء مستودع أو رفع أي ملفات:

```powershell
.\scripts\APPLY_WINDOWS.ps1 -DryRun
```

4. بعد التأكد من التغييرات، انشر:

```powershell
.\scripts\APPLY_WINDOWS.ps1
```

اكتب `APPLY` عندما يطلب السكربت التأكيد. لو لم ترد النشر، اكتب أي شيء آخر. السكربت يحدد الحساب مسبقًا، يحافظ على الملفات خارج المسارات التي يديرها، ويحفظ نسخة محلية من README القديم قبل الاستبدال. لا يستخدم force push.

> إذا ظهر خطأ Execution Policy في Windows PowerShell، يمكن تشغيل السكربت لجلسة واحدة من دون تغيير السياسة الدائمة:
>
> ```powershell
> powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\APPLY_WINDOWS.ps1" -DryRun
> powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\APPLY_WINDOWS.ps1"
> ```

## Linux / macOS

```bash
cd /path/to/RUSHERBUILDS_PROFILE_ENHANCED
gh auth login -h github.com
gh auth setup-git
gh api user --jq .login
bash scripts/APPLY_LINUX_MAC.sh --dry-run
bash scripts/APPLY_LINUX_MAC.sh
```

آخر أمر يطلب كتابة `APPLY` أيضًا.

## بعد النشر

1. افتح [مستودع البروفايل](https://github.com/rusherbuilds/rusherbuilds)، وتأكد أن `README.md` ظهر.
2. لتوليد حركة Pac-Man/Snake، من تبويب **Actions** اختر **Build contribution arcade** ثم **Run workflow**. بديل CLI:

```powershell
gh workflow run contribution-arcade.yml -R rusherbuilds/rusherbuilds
```

3. لنشر صفحة الـPortfolio: **Settings → Pages → Build and deployment → Deploy from a branch**. اختر الـdefault branch للمستودع (غالبًا `main`) والمجلد `/docs`، ثم **Save**. يمكنك معرفة اسم الفرع الصحيح عبر:

```powershell
gh api repos/rusherbuilds/rusherbuilds --jq .default_branch
```

4. عندما يكتمل النشر، الرابط المتوقع: [rusherbuilds.github.io/rusherbuilds](https://rusherbuilds.github.io/rusherbuilds/).

## ملاحظات مهمة

- صورة `assets/avatar.png` تظهر داخل README، وصورة `docs/avatar.png` داخل الموقع؛ **لا يمكن تغيير صورة الحساب الرئيسية تلقائيًا من README**. لتغييرها افتح [إعدادات صورة GitHub](https://github.com/settings/profile).
- قد تحتاج إلى تفعيل GitHub Actions والسماح بكتابة `GITHUB_TOKEN` على فرع `output` بحسب سياسة المستودع.
- النشر يستبدل النسخ الموجودة من الملفات ذات الأسماء المتطابقة ضمن المسارات المدارة، فلا تستخدمه دون مراجعة `-DryRun`. احتفظ بالحزمة الأصلية أيضًا.
- لا ترفع مفاتيح API أو ملفات `.env` إلى المستودع العام.
