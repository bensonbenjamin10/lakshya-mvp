import 'package:flutter/material.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final testimonials = [
      {
        'name': 'Priya Sharma',
        'course': 'ACCA',
        'text': 'Lakshya Institute helped me achieve my ACCA qualification. The faculty is excellent and the support throughout the journey was incredible.',
        'rating': 5,
      },
      {
        'name': 'Rahul Kumar',
        'course': 'CA',
        'text': 'The comprehensive CA program at Lakshya prepared me well for my career. I\'m now working at a top accounting firm.',
        'rating': 5,
      },
      {
        'name': 'Anjali Patel',
        'course': 'CMA (US)',
        'text': 'The CMA program opened doors to international opportunities. The course structure and guidance were outstanding.',
        'rating': 5,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'What Our Students Say',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: testimonials.length,
              itemBuilder: (context, index) {
                final testimonial = testimonials[index];
                return Container(
                  width: 350,
                  margin: const EdgeInsets.only(right: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(
                              testimonial['rating'] as int,
                              (i) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            testimonial['text'] as String,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Spacer(),
                          const SizedBox(height: 12),
                          Text(
                            testimonial['name'] as String,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            testimonial['course'] as String,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

