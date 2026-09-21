import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HelpAccordionDialog extends StatelessWidget {
  const HelpAccordionDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HelpAccordionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> helpTopics = [
      {
        'title': 'مقدمة',
        'content':
            'مرحباً بك مع برنامج دفتر الحسابات.\nدقة، سهولة، أمان.\n\nبالإضافة إلى سهولة الاستخدام، يوفر لك هذا البرنامج:\n'
            '1- متابعة المبالغ الدائنة والمدينة.\n'
            '2- إنجاز الحسابات التجميعية آلياً.\n'
            '3- مشاركة الحسابات عبر البلوتوث أو مواقع التواصل الاجتماعي.\n'
            '4- دالة بحث وترتيب تُمكّنك من الوصول السهل والسريع.\n'
            '5- خاصية التصدير والاستيراد لقاعدة البيانات.',
      },
      {
        'title': 'سياسة الخصوصية',
        'content':
            'يتطلب دفتر الحسابات إمكانية الوصول إلى أشياء محددة في جهازك لغرض تسهيل تعاملك:\n\n'
            '• الوصول إلى الجهاز: للتعرف على طريقة الاستخدام، ولا يوجد أي خطر يترتب على هذه الميزة.\n'
            '• الوصول إلى الأسماء: لا نرسل الأسماء إلى أي جهة خارجية؛ الميزة فقط لتسهيل استيراد جهات الاتصال.\n'
            '• الوصول إلى الحسابات: مطلوب للنسخ الاحتياطي على Google Drive الخاص بك فقط.',
      },
      {
        'title': 'إضافة مبلغ',
        'content':
            'يمكنك ذلك بطريقتين:\n\n'
            '1- بالنقر على زر إضافة مبلغ (+) أسفل الشاشة:\n'
            'ستظهر لك صفحة إضافة عملية؛ قم بإدخال الاسم (إذا كان جديداً) أو اختياره من القائمة، وحدد المبلغ والتاريخ والعملة، ثم انقر على (عليه) أو (له).\n\n'
            '2- بالنقر على زر الإضافة (+) الموجود بجانب الاسم في كشف الحساب.',
      },
      {
        'title': 'طباعة ومشاركة البيانات',
        'content':
            'يوفر دفتر الحسابات العديد من الإمكانيات لمشاركة حساباتك:\n\n'
            '1- طباعة: تصدير بيانات الحساب إلى ملف PDF جاهز للطباعة على ورق، متضمناً بياناتك وشعارك.\n\n'
            '2- مشاركة: إرسال بيانات حساب معين عبر وسائل التواصل الاجتماعي بصيغ PDF ونص وصورة.',
      },
      {
        'title': 'الإعدادات',
        'content':
            '1- البيانات الشخصية: تعبئة الاسم والمؤسسة والهاتف والعنوان والشعار لاستخدامها في التقارير والـ PDF.\n'
            '2- خيارات الطباعة: التحكم بظهور الشعار والبيانات.\n'
            '3- خيارات الأمان: تعيين كلمة مرور / رمز قفل لحماية البيانات.\n'
            '4- خيارات العملات والتصنيفات: إدارة العملات والتصنيفات وإضافتها.\n'
            '5- خيارات حفظ البيانات: الحفظ التلقائي للبيانات يومياً محلياً وعبر درايف.\n'
            '6- استعراض البيانات من الكمبيوتر: إمكانية استعراض البيانات عبر الشبكة المحلية.',
      },
      {
        'title': 'إغلاق الحساب',
        'content':
            'تمكنك هذه الخاصية من تسوية سجلات العمليات المسجلة لعميل أو مورد وتجميعها في عملية واحدة برصيد مرحل أو تصفير الحساب عند إتمام المحاسبة.',
      },
      {
        'title': 'التقارير',
        'content':
            'يحتوي دفتر الحسابات على مجموعة متكاملة من التقارير:\n'
            '• تقرير إجمالي المبالغ\n'
            '• تقرير تفاصيل كل المبالغ\n'
            '• تقرير إجمالي المبالغ شهرياً\n'
            '• تقرير إجمالي التصنيفات\n'
            '• تقرير حركة الحسابات',
      },
      {
        'title': 'البحث',
        'content':
            'يمكنك البحث عن (اسم، مبلغ، تاريخ، أو جزء من الوصف). يدعم البحث الفوري أثناء الكتابة وتصفية البيانات بدقة.',
      },
      {
        'title': 'الترتيب',
        'content':
            'يمكنك إعادة عرض البيانات بالترتيب المرغوب بالنقر على خيار الترتيب: تصاعدياً أو تنازلياً حسب الاسم أو التاريخ أو الرصيد.',
      },
      {
        'title': 'حذف/تعديل البيانات',
        'content':
            'النقر مطولاً على اسم الزبون أو العملية يسمح لك بالتعديل أو الحذف من خلال القائمة أو أيقونات التعديل والحذف العلوية.',
      },
      {
        'title': 'حماية قاعدة البيانات/ النسخ الإحتياطي',
        'content':
            'من المهم للغاية الاحتفاظ بنسخة احتياطية من بياناتك من وقت لآخر.\n'
            'يوجد خيار "حفظ نسخة إحتياطية" لمشاركة الملف أو حفظه، وخيار "إسترجاع قاعدة البيانات" لاستعادة بياناتك في أي وقت.',
      },
      {
        'title': 'التصنيفات والعملات',
        'content':
            'يمكنك إضافة أكثر من تصنيف أو عملة داخل البرنامج من شاشة الإعدادات. كما يمكنك التنقل بين التصنيفات من الشاشة الرئيسية، واختيار العملة المناسبة لكل عملية.',
      },
      {
        'title': 'التواصل والدعم الفني',
        'content':
            'يرجى التواصل مع المطور أسامة العقاب عبر البريد الالكتروني osamaalokab24@gmail.com او عبر الواتساب https://wa.me/967780086263',
      },
    ];

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'دليل استخدام دفتر الحسابات',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: helpTopics.length,
              itemBuilder: (context, index) {
                final topic = helpTopics[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      topic['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          topic['content']!,
                          style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
