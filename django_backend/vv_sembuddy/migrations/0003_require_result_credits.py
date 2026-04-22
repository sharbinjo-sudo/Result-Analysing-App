from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("vv_sembuddy", "0002_notice_result_user_fields"),
    ]

    operations = [
        migrations.AlterField(
            model_name="result",
            name="credits",
            field=models.DecimalField(decimal_places=1, max_digits=4),
        ),
    ]
