import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/api_service.dart';
import '../../theme.dart';
import '../../widgets/college_scaffold.dart';
import '../../widgets/dashboard_parts.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key, required this.role});

  final String role;

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  late Future<List<dynamic>> _future;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getNotices();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => _future = ApiService.getNotices());
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showUploadDialog() async {
    PlatformFile? selectedFile;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Publish Notice'),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create a notice for the whole campus and optionally attach a PDF.',
                        style: TextStyle(color: kTextLight, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        minLines: 3,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kSurfaceTint,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: kAccentColor.withValues(alpha: 0.35)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Attachment',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              selectedFile?.name ?? 'Attach an optional PDF circular or timetable.',
                              style: const TextStyle(color: kTextLight, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final result = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  withData: true,
                                  allowedExtensions: const ['pdf'],
                                );
                                if (result != null && result.files.isNotEmpty) {
                                  setDialogState(() => selectedFile = result.files.first);
                                }
                              },
                              icon: const Icon(Icons.attach_file_outlined),
                              label: Text(
                                selectedFile == null ? 'Choose PDF' : 'Change PDF',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _uploading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: _uploading
                      ? null
                      : () async {
                          Navigator.pop(context);
                          await _uploadNotice(file: selectedFile);
                        },
                  icon: const Icon(Icons.publish_outlined),
                  label: Text(_uploading ? 'Publishing...' : 'Publish'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _uploadNotice({PlatformFile? file}) async {
    if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      _showMessage('Add a title and description before publishing the notice.');
      return;
    }

    setState(() => _uploading = true);
    try {
      await ApiService.uploadNotice(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        fileName: file?.name,
        bytes: file?.bytes,
      );
      _titleController.clear();
      _descriptionController.clear();
      _reload();
      _showMessage('Notice published successfully.');
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  Future<void> _showAttachmentInfo(Map<String, dynamic> notice) async {
    final url = notice['attachment_url']?.toString() ?? '';
    final name = notice['attachment_name']?.toString() ?? '';

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name.isEmpty ? 'Notice Attachment' : name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Use the link below to open or download the uploaded PDF notice.',
              style: TextStyle(color: kTextLight, height: 1.5),
            ),
            const SizedBox(height: 14),
            SelectableText(
              url.isEmpty ? 'No attachment is available for this notice.' : url,
            ),
          ],
        ),
        actions: [
          if (url.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: url));
                if (context.mounted) {
                  Navigator.pop(context);
                }
                _showMessage('Attachment link copied.');
              },
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy Link'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.role == 'admin';

    return CollegeScaffold(
      title: 'College Notices',
      role: widget.role,
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: _uploading ? null : _showUploadDialog,
              backgroundColor: kPrimaryColor,
              label: Text(_uploading ? 'Publishing...' : 'Publish Notice'),
              icon: const Icon(Icons.campaign_outlined),
            )
          : null,
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')));
          }

          final notices = List<Map<String, dynamic>>.from(snapshot.data ?? const []);
          final attachmentsCount = notices
              .where((notice) => (notice['attachment_name']?.toString().isNotEmpty ?? false))
              .length;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              DashboardHero(
                title: 'College Circulars',
                subtitle:
                    'Important announcements, exam schedules, and official updates loaded directly from the backend.',
                badges: [
                  '${notices.length} Notices',
                  '$attachmentsCount PDF Attachments',
                  isAdmin ? 'Admin publishing enabled' : 'Read-only notice feed',
                ],
              ),
              const SizedBox(height: 24),
              SummaryGrid(
                stats: {
                  'published_notices': notices.length,
                  'pdf_attachments': attachmentsCount,
                  'latest_update': notices.isEmpty ? '-' : _formatDate(notices.first['created_at']),
                },
              ),
              if (isAdmin) ...[
                const SizedBox(height: 24),
                ActionCard(
                  title: 'Publish a New Circular',
                  description:
                      'Share official notices with the whole campus and optionally attach a PDF document.',
                  icon: Icons.upload_file_outlined,
                  onTap: _showUploadDialog,
                ),
              ],
              const SizedBox(height: 24),
              const SectionTitle(
                title: 'Latest Notices',
                subtitle:
                    'Every item below is served from the backend and reflects the latest published records.',
              ),
              const SizedBox(height: 16),
              if (notices.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No notices have been published yet.'),
                  ),
                )
              else
                ...notices.map(
                  (notice) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _NoticeCard(
                      notice: notice,
                      onAttachmentTap: () => _showAttachmentInfo(notice),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.notice,
    required this.onAttachmentTap,
  });

  final Map<String, dynamic> notice;
  final VoidCallback onAttachmentTap;

  @override
  Widget build(BuildContext context) {
    final attachmentName = notice['attachment_name']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFFFFBF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.notifications_active_outlined, color: kPrimaryColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice['title']?.toString() ?? 'Notice',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: kTextDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notice['description']?.toString() ?? '',
                        style: const TextStyle(height: 1.6, color: kTextLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetaChip(
                  icon: Icons.person_outline,
                  label: notice['created_by_name']?.toString() ?? 'Admin',
                ),
                _MetaChip(
                  icon: Icons.schedule_outlined,
                  label: _formatDate(notice['created_at']),
                ),
              ],
            ),
            if (attachmentName.isNotEmpty) ...[
              const SizedBox(height: 18),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onAttachmentTap,
                child: Ink(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kSurfaceTint,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kAccentColor.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.picture_as_pdf_outlined, color: kPrimaryColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Attached Document',
                              style: TextStyle(
                                color: kTextLight,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              attachmentName,
                              style: const TextStyle(
                                color: kTextDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.open_in_new_outlined, color: kPrimaryColor),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: kPrimaryColor),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: kTextDark, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

String _formatDate(dynamic rawValue) {
  final raw = rawValue?.toString() ?? '';
  if (raw.isEmpty) {
    return '-';
  }

  final parsed = DateTime.tryParse(raw)?.toLocal();
  if (parsed == null) {
    return raw.replaceFirst('T', ' ');
  }

  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
  final minute = parsed.minute.toString().padLeft(2, '0');
  final suffix = parsed.hour >= 12 ? 'PM' : 'AM';
  return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year} | $hour:$minute $suffix';
}
