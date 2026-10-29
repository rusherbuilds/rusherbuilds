# RUSHERBUILDS • GitHub Profile Ready Repository

هذه حزمة **Git Repository Source** جاهزة لحساب `rusherbuilds`، وتم تحسينها لتشمل الصورة المرفقة وفحصًا قبل النشر:
- `README.md`: بانر متحرك + جدول Property/Data + صف **My Projects** وصف **My Tools & Utilities** + إحصائيات + Pac-Man/Snake
- `.github/workflows/contribution-arcade.yml`: تحديث أنيميشن المساهمات أوتوماتيكيًا
- `assets/`: بانر GIF ومعاينة
- `docs/`: صفحة Portfolio متحركة للنشر باستخدام GitHub Pages
- `scripts/`: نشر تلقائي آمن يتحقق من الحساب أولاً
- `DEPLOY_COMMANDS_AR.md`: جميع أوامر Windows / Linux / macOS بالترتيب، ومنها وضع المعاينة

## أسرع طريقة تطبيق (Windows)

1. فك ضغط `RUSHERBUILDS_READY_REPO.zip`.
2. ثبّت [Git for Windows](https://git-scm.com/download/win) و[GitHub CLI](https://cli.github.com/).
3. في PowerShell نفّذ `gh auth login` وسجّل الدخول بحساب **rusherbuilds** تحديدًا.
4. ادخل المجلد المفتوح (الذي يحتوي `README.md` و`scripts`)، واعرض التغييرات أولاً:

```powershell
.\scripts\APPLY_WINDOWS.ps1 -DryRun
```

5. بعد المراجعة شغّل:

```powershell
.\scripts\APPLY_WINDOWS.ps1
```

6. اكتب `APPLY` للتأكيد. السكربت ينشئ Repository عامة باسم `rusherbuilds/rusherbuilds` إذا لم تكن موجودة، أو يرفع الملفات إليها بعد أخذ نسخة احتياطية محلية من README.
7. افتح `https://github.com/rusherbuilds` لرؤية البروفايل فور نجاح الـpush.
8. من مستودع `rusherbuilds/rusherbuilds`: Actions > **Build contribution arcade** > **Run workflow**. ثم Settings > Pages > Deploy from a branch > الفرع الافتراضي > `/docs` > Save.

**جميع أوامر النشر التفصيلية موجودة في `DEPLOY_COMMANDS_AR.md`.**

**مهم:** GitHub Importer (`github.com/new/import`) لا يستقبل ملفات ZIP. يتطلب رابط Git repository منشورة مسبقاً. لذلك هذا السكربت يعمل إنشاء + رفع مباشرة وهو أقرب شيء للـApply التلقائي. لا تضع ZIP نفسها في Upload files؛ فك الضغط وارفع **محتوياتها**.

## بدون برامج: من واجهة GitHub فقط

1. أنشئ Public repository بنفس اسم المستخدم: `rusherbuilds` من `https://github.com/new`.
2. **Add file > Upload files** ثم ارفع الملفات والمجلدات بعد فك الضغط (يجب أن يحتفظ ملف الـworkflow بالمسار `.github/workflows/contribution-arcade.yml`). بعض واجهات الرفع تخفي الملفات/الفولدرات التي تبدأ بنقطة؛ استخدم محرر الملف مباشرة لإضافتها إذا لزم.
3. Commit changes. أيقونات الجدول ستظهر مباشرة، والأنيميشن المعتمدة على workflow تظهر بعد تشغيل Action.
4. GitHub Pages: Settings > Pages > branch `main`, folder `/docs`.

## إضافة المشاريع والأدوات

في `README.md` ابحث عن `PROJECTS_ROW_START` و `TOOLS_ROW_START`.

مثال badge مربوط بمشروعك:
```html
<a href="https://github.com/rusherbuilds/PROJECT_NAME"><img alt="Project" src="https://img.shields.io/badge/PROJECT_NAME-0D8ABC?style=flat-square&logo=github&logoColor=white" /></a>
```
يمكنك نسخ سطر Badge لأي مشروع أو أداة مع تغيير الرابط والاسم.

الموقع المنفصل: أضف أدوات الموقع في `docs/config.js` عند `myTools` بهذا الشكل:
```js
myTools: [
  { name: 'My Tool', description: 'Tool description', url: 'https://github.com/rusherbuilds/my-tool', status: 'Open Source' }
],
```
المشاريع العامة تظهر في الموقع تلقائيًا من GitHub API (بدون اختلاق مشاريع أو أرقام).

## هام قبل النشر

- الملف مصمم خصيصاً لـ`rusherbuilds` ولن ينشر على حساب متصل آخر دون تسجيل دخول به.
- لا تضع Tokens أو Secrets داخل ملفات الموقع.
- راجع Badge المهارات وعدّل غير المستخدم منها. بعض التخصصات والأدوات قوالب وليست شهادات مهارة.
- الصور الخارجية والإحصائيات تعتمد على خدمات خارجية؛ قد لا تظهر إن تعطلت أو وصلتها حدود الاستخدام.
- GitHub Profile README يظهر فقط داخل مستودع عام مطابق لاسم المستخدم، وعلى الـdefault branch.
- قد يحتاج الـworkflow تفعيل GitHub Actions أو تفعيل `Read and write permissions` إذا كانت سياسة المستودع تمنع الكتابة، مع وجود `permissions: contents: write` بالـworkflow.
- إذا كان الـbranch الافتراضي مختلفاً عن `main` عند إنشاء المستودع، عدّل إعدادات GitHub Pages والـworkflow accordingly.
