import 'package:flutter/material.dart';

class MaimaiDifficultySelector extends StatefulWidget {
  final Color activeColor;
  final VoidCallback onImport;

  const MaimaiDifficultySelector({
    super.key,
    required this.activeColor,
    required this.onImport,
  });

  @override
  State<MaimaiDifficultySelector> createState() =>
      _MaimaiDifficultySelectorState();
}

class _MaimaiDifficultySelectorState extends State<MaimaiDifficultySelector> {
  // 0: Basic, 1: Advanced, 2: Expert, 3: Master, 4: Re:Master, 5: Utage
  final Set<int> _selectedDifficulties = {0, 1, 2, 3, 4, 5};

  final List<Map<String, dynamic>> _difficulties = [
    {
      'name': 'Basic',
      'asset': 'assets/background/maimaidx/difficulty/basic.png',
      // 45c124
      'color': const Color(0xFF45C124),
    },
    {
      'name': 'Advanced',
      'asset': 'assets/background/maimaidx/difficulty/advanced.png',
      // ffba01
      'color': const Color(0xFFFFBA01),
    },
    {
      'name': 'Expert',
      'asset': 'assets/background/maimaidx/difficulty/expert.png',
      // ff5a66
      'color': const Color(0xFFFF5A66),
    },
    {
      'name': 'Master',
      'asset': 'assets/background/maimaidx/difficulty/master.png',
      // 9f51dc
      'color': const Color(0xFF9F51DC),
    },
    {
      'name': 'Re:Master',
      'asset': 'assets/background/maimaidx/difficulty/remaster.png',
      // e6e6e6
      'color': const Color(0xFFE6E6E6),
    },
    {
      'name': 'Utage',
      'asset': 'assets/background/maimaidx/difficulty/utage.png',
      // ff6ffd
      'color': const Color(0xFFFF6FFD),
    },
  ];

  void _toggleDifficulty(int index) {
    setState(() {
      if (_selectedDifficulties.contains(index)) {
        _selectedDifficulties.remove(index);
      } else {
        _selectedDifficulties.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: _difficulties.length,
          itemBuilder: (context, index) {
            final difficulty = _difficulties[index];
            final isSelected = _selectedDifficulties.contains(index);
            final color = difficulty['color'] as Color;
            final isRemaster = index == 4; // Re:Master is index 4

            return GestureDetector(
              onTap: () => _toggleDifficulty(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: isRemaster
                                ? Colors.black.withOpacity(0.1)
                                : color.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                padding: const EdgeInsets.all(6),
                alignment: Alignment.center,
                child: SizedBox(
                  height: 28, // Strictly enforced height for image consistency
                  child: isSelected
                      ? SizedBox(
                          height: 28,
                          child: Image.asset(
                            difficulty['asset'],
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                        )
                      : ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                          child: Opacity(
                            opacity: 0.6,
                            child: SizedBox(
                              height: 28,
                              child: Image.asset(
                                difficulty['asset'],
                                height: 28,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: _selectedDifficulties.isEmpty ? null : widget.onImport,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.activeColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0, // Flat style to match design
            ),
            child: const Text(
              '开始导入',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
