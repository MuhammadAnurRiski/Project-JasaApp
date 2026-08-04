import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/models/portfolio_item.dart';
import '../../../../core/utils/image_url.dart';
import '../providers/provider_profile_provider.dart';

class ProviderProfileEditScreen extends ConsumerStatefulWidget {
  const ProviderProfileEditScreen({super.key});

  @override
  ConsumerState<ProviderProfileEditScreen> createState() => _ProviderProfileEditScreenState();
}

class _ProviderProfileEditScreenState extends ConsumerState<ProviderProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _fullNameCtrl;
  late TextEditingController _nicknameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _birthDateCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _domicileCtrl;
  String _gender = '';
  bool _submitting = false;
  String? _profilePhotoPath;
  List<String> _existingPortfolios = [];
  final List<NewPortfolioFile> _newPortfolioFiles = [];
  final List<PortfolioItem> _newPortfolioLinks = [];
  bool _hasChanges = false;

  int get _portfolioCount =>
      _existingPortfolios.length + _newPortfolioFiles.length + _newPortfolioLinks.length;

  @override
  void initState() {
    super.initState();
    final s = ref.read(profileProvider);
    _fullNameCtrl = TextEditingController(text: s.fullName ?? '');
    _nicknameCtrl = TextEditingController(text: s.nickname ?? '');
    _phoneCtrl = TextEditingController(text: s.phone ?? '');
    _birthDateCtrl = TextEditingController(text: s.birthDate ?? '');
    _addressCtrl = TextEditingController(text: s.address ?? '');
    _domicileCtrl = TextEditingController(text: s.domicile ?? '');
    final rawGender = s.gender ?? '';
    if (rawGender.isNotEmpty) {
      const validGenders = ['Laki-laki', 'Perempuan'];
      _gender = validGenders.firstWhere(
        (g) => g.toLowerCase() == rawGender.toLowerCase(),
        orElse: () => '',
      );
    }
    _existingPortfolios = s.portfolios.map((e) => e.encode()).toList();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _nicknameCtrl.dispose();
    _phoneCtrl.dispose();
    _birthDateCtrl.dispose();
    _addressCtrl.dispose();
    _domicileCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _birthDateCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _hasChanges = true;
    }
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih Sumber',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galeri'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Kamera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final x = await _picker.pickImage(source: source);
    if (x != null) {
      setState(() {
        _profilePhotoPath = x.path;
        _hasChanges = true;
      });
    }
  }

  Future<void> _showAddPortfolioMenu() async {
    if (_portfolioCount >= 5) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Tambah Portofolio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Foto'),
              subtitle: const Text('Unggah gambar'),
              onTap: () => Navigator.pop(context, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: const Text('File'),
              subtitle: const Text('PDF, DOC, XLS, PPT, ZIP'),
              onTap: () => Navigator.pop(context, 'file'),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Link'),
              subtitle: const Text('Tautan eksternal'),
              onTap: () => Navigator.pop(context, 'link'),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    switch (choice) {
      case 'image':
        await _pickPortfolioImages();
        break;
      case 'file':
        await _pickPortfolioFile();
        break;
      case 'link':
        await _addPortfolioLink();
        break;
    }
  }

  Future<void> _pickPortfolioImages() async {
    final remaining = 5 - _portfolioCount;
    if (remaining <= 0) return;
    final xs = await _picker.pickMultiImage(limit: remaining);
    if (xs.isEmpty) return;
    setState(() {
      for (final x in xs) {
        if (_portfolioCount >= 5) break;
        _newPortfolioFiles.add(NewPortfolioFile(
          file: File(x.path),
          type: PortfolioType.image,
        ));
      }
      _hasChanges = true;
    });
  }

  Future<void> _pickPortfolioFile() async {
    final remaining = 5 - _portfolioCount;
    if (remaining <= 0) return;
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: remaining > 1,
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'zip',
      ],
    );
    if (result == null || result.files.isEmpty) return;
    setState(() {
      for (final f in result.files) {
        if (_portfolioCount >= 5) break;
        final path = f.path;
        if (path == null) continue;
        _newPortfolioFiles.add(NewPortfolioFile(
          file: File(path),
          type: PortfolioType.file,
          label: f.name,
        ));
      }
      _hasChanges = true;
    });
  }

  Future<void> _addPortfolioLink() async {
    final urlCtrl = TextEditingController();
    final labelCtrl = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul (opsional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
    final url = urlCtrl.text.trim();
    final label = labelCtrl.text.trim();
    urlCtrl.dispose();
    labelCtrl.dispose();
    if (!mounted) return;
    if (saved != true || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('URL tidak valid. Gunakan http:// atau https://')),
      );
      return;
    }
    setState(() {
      _newPortfolioLinks.add(PortfolioItem(
        type: PortfolioType.link,
        url: url,
        label: label,
      ));
      _hasChanges = true;
    });
  }

  void _removeExistingPortfolio(int index) {
    setState(() {
      _existingPortfolios.removeAt(index);
      _hasChanges = true;
    });
  }

  void _removeNewPortfolio(int index) {
    setState(() {
      _newPortfolioFiles.removeAt(index);
      _hasChanges = true;
    });
  }

  void _removeNewPortfolioLink(int index) {
    setState(() {
      _newPortfolioLinks.removeAt(index);
      _hasChanges = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges &&
        _profilePhotoPath == null &&
        _newPortfolioFiles.isEmpty &&
        _newPortfolioLinks.isEmpty) {
      Navigator.pop(context, false);
      return;
    }

    setState(() => _submitting = true);

    final ok = await ref.read(profileProvider.notifier).updateProfile(
      fullName: _fullNameCtrl.text.trim(),
      nickname: _nicknameCtrl.text.trim(),
      gender: _gender,
      birthDate: _birthDateCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      domicile: _domicileCtrl.text.trim(),
      profilePhotoPath: _profilePhotoPath,
      portfolios: [
        ..._existingPortfolios,
        ..._newPortfolioLinks.map((e) => e.encode()),
      ],
      newPortfolioFiles: _newPortfolioFiles,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      final err = ref.read(profileProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Gagal menyimpan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: _submitting ? null : _save,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Simpan',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickPhoto,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _profilePhotoPath != null
                              ? FileImage(File(_profilePhotoPath!))
                              : ref.read(profileProvider).profilePhoto != null
                                  ? NetworkImage(imageUrl(ref.read(profileProvider).profilePhoto))
                                  : null,
                          backgroundColor: const Color(0xFFE8F5E9),
                          child: _profilePhotoPath == null && ref.read(profileProvider).profilePhoto == null
                              ? const Icon(Icons.person,
                                  size: 50, color: Color(0xFF00A651))
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF00A651),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildField('Nama Lengkap', _fullNameCtrl, true),
                _buildField('Nama Panggilan', _nicknameCtrl, true),
                _buildField('Nomor HP', _phoneCtrl, true,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                Text('Jenis Kelamin',
                    style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _gender.isEmpty ? null : _gender,
                  items: const [
                    DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                    DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _gender = v ?? '';
                      _hasChanges = true;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Tanggal Lahir',
                    style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _birthDateCtrl,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    hintText: 'Pilih tanggal lahir',
                    suffixIcon: const Icon(Icons.calendar_today, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
                _buildField('Alamat', _addressCtrl, true, maxLines: 2),
                _buildField('Domisili', _domicileCtrl, true),
                const SizedBox(height: 24),
                _buildPortfolioSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Portofolio',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface)),
            TextButton.icon(
              onPressed: _portfolioCount >= 5 ? null : _showAddPortfolioMenu,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
              label: const Text('Tambah'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_portfolioCount == 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Icon(Icons.photo_library_outlined, size: 40, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text('Belum ada portofolio', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._existingPortfolios.asMap().entries.map((e) => _buildPortfolioItemView(
                item: PortfolioItem.fromEncoded(e.value),
                onDelete: () => _removeExistingPortfolio(e.key),
              )),
              ..._newPortfolioFiles.asMap().entries.map((e) => _buildPortfolioItemView(
                newFile: e.value,
                onDelete: () => _removeNewPortfolio(e.key),
              )),
              ..._newPortfolioLinks.asMap().entries.map((e) => _buildPortfolioItemView(
                item: e.value,
                onDelete: () => _removeNewPortfolioLink(e.key),
              )),
            ],
          ),
        const SizedBox(height: 4),
        Text('Maksimal 5 item (gambar, file, atau link)',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
      ],
    );
  }

  Widget _buildPortfolioItemView({
    PortfolioItem? item,
    NewPortfolioFile? newFile,
    required VoidCallback onDelete,
  }) {
    if (newFile != null) {
      if (newFile.type == PortfolioType.image) {
        return _buildPortfolioThumb(
          child: Image.file(newFile.file, fit: BoxFit.cover),
          onDelete: onDelete,
        );
      }
      return _buildPortfolioChip(
        icon: Icons.insert_drive_file_outlined,
        label: newFile.label,
        onDelete: onDelete,
      );
    }
    if (item == null) return const SizedBox.shrink();
    switch (item.type) {
      case PortfolioType.image:
        return _buildPortfolioThumb(
          child: Image.network(
            imageUrl(item.url),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFF1F5F9),
              child: const Icon(Icons.broken_image, color: Color(0xFF94A3B8)),
            ),
          ),
          onDelete: onDelete,
        );
      case PortfolioType.file:
        return _buildPortfolioChip(
          icon: Icons.insert_drive_file_outlined,
          label: item.displayLabel,
          onDelete: onDelete,
        );
      case PortfolioType.link:
        return _buildPortfolioChip(
          icon: Icons.link,
          label: item.displayLabel,
          onDelete: onDelete,
        );
    }
  }

  Widget _buildPortfolioThumb({
    required Widget child,
    required VoidCallback onDelete,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 90,
            height: 90,
            child: child,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioChip({
    required IconData icon,
    required String label,
    required VoidCallback onDelete,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 160,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: const Color(0xFF00A651)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, bool required,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
            validator: required
                ? (v) => v == null || v.trim().isEmpty ? '$label wajib diisi' : null
                : null,
            onChanged: (_) => _hasChanges = true,
          ),
        ],
      ),
    );
  }
}
