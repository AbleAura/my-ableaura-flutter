// lib/services/insights_generator.dart

import '../models/progress_models.dart';

class InsightsResponse {
  final String analysis;
  final List<String> recommendations;

  InsightsResponse({
    required this.analysis,
    required this.recommendations,
  });
}

class InsightsGenerator {
  static InsightsResponse generateInsights(List<DailyProgress> events) {
    if (events.isEmpty) {
      return InsightsResponse(
        analysis: 'No evaluations recorded for this period.',
        recommendations: [],
      );
    }

    // Group events by skill
    final skillGroups = events.fold<Map<String, List<DailyProgress>>>(
      {},
      (map, event) {
        if (!map.containsKey(event.skillName)) {
          map[event.skillName] = [];
        }
        map[event.skillName]!.add(event);
        return map;
      },
    );

    final analysis = _generateAnalysis(skillGroups);
    final recommendations = _generateRecommendations(skillGroups);

    return InsightsResponse(
      analysis: analysis,
      recommendations: recommendations,
    );
  }

  static String _generateAnalysis(Map<String, List<DailyProgress>> skillGroups) {
    final buffer = StringBuffer();
    
    buffer.write('This month\'s evaluation covers ${skillGroups.length} key developmental areas. ');

    skillGroups.forEach((skillName, events) {
      buffer.write('\n\n$skillName: ');
      
      // Calculate average levels using getLevelValue
      double avgSupport = events
          .map((e) => e.getLevelValue(e.supportLevel))
          .reduce((a, b) => a + b) / events.length;
      double avgInstruction = events
          .map((e) => e.getLevelValue(e.instructionLevel))
          .reduce((a, b) => a + b) / events.length;
      double avgPerformance = events
          .map((e) => e.getLevelValue(e.performanceLevel))
          .reduce((a, b) => a + b) / events.length;

      // Generate skill-specific analysis
      if (avgPerformance >= 8) {
        buffer.write('Showing excellent progress with high performance. ');
      } else if (avgPerformance >= 4) {
        buffer.write('Demonstrating steady improvement. ');
      } else {
        buffer.write('Building foundational skills. ');
      }

      if (avgSupport <= 2) {
        buffer.write('Currently requires consistent support. ');
      } else if (avgSupport <= 5) {
        buffer.write('Becoming more independent with guidance. ');
      } else {
        buffer.write('Shows strong independence. ');
      }

      if (avgInstruction >= 8) {
        buffer.write('Excellent understanding of instructions. ');
      } else if (avgInstruction >= 4) {
        buffer.write('Good grasp of instructions with occasional guidance needed. ');
      } else {
        buffer.write('Working on following instructions more effectively. ');
      }

      // Add skill-specific insights
      switch (skillName.toLowerCase()) {
        case 'walking':
          buffer.write(_generateWalkingInsights(events));
          break;
        case 'running':
          buffer.write(_generateRunningInsights(events));
          break;
        case 'throwing':
          buffer.write(_generateThrowingInsights(events));
          break;
        case 'jumping':
          buffer.write(_generateJumpingInsights(events));
          break;
        case 'kicking':
          buffer.write(_generateKickingInsights(events));
          break;
      }
    });

    return buffer.toString();
  }

  static String _generateSkillInsights(List<DailyProgress> events, String skillDescription) {
    final avgPerformance = events
        .map((e) => e.getLevelValue(e.performanceLevel))
        .reduce((a, b) => a + b) / events.length;
    
    if (avgPerformance >= 8) {
      return 'Demonstrates excellent $skillDescription abilities. ';
    } else if (avgPerformance >= 4) {
      return 'Making good progress in $skillDescription skills. ';
    } else {
      return 'Building foundational $skillDescription abilities. ';
    }
  }

  static String _generateWalkingInsights(List<DailyProgress> events) =>
      _generateSkillInsights(events, 'walking');

  static String _generateRunningInsights(List<DailyProgress> events) =>
      _generateSkillInsights(events, 'running');

  static String _generateJumpingInsights(List<DailyProgress> events) =>
      _generateSkillInsights(events, 'jumping');

  static String _generateThrowingInsights(List<DailyProgress> events) =>
      _generateSkillInsights(events, 'throwing');

  static String _generateKickingInsights(List<DailyProgress> events) =>
      _generateSkillInsights(events, 'kicking');

  static List<String> _generateRecommendations(Map<String, List<DailyProgress>> skillGroups) {
    final recommendations = <String>[];

    skillGroups.forEach((skillName, events) {
      final avgPerformance = events
          .map((e) => e.getLevelValue(e.performanceLevel))
          .reduce((a, b) => a + b) / events.length;
      
      final avgSupport = events
          .map((e) => e.getLevelValue(e.supportLevel))
          .reduce((a, b) => a + b) / events.length;

      final avgInstruction = events
          .map((e) => e.getLevelValue(e.instructionLevel))
          .reduce((a, b) => a + b) / events.length;

      // General recommendations based on levels
      if (avgPerformance <= 3) {
        recommendations.add('Focus on basic $skillName exercises with close supervision');
        recommendations.add('Break down $skillName activities into smaller steps');
      }

      // Add specific recommendations based on support level
      if (avgSupport <= 5) {
        recommendations.add('Continue providing guided support for $skillName activities');
      }

      // Add recommendations based on instruction level
      if (avgInstruction <= 5) {
        recommendations.add('Use visual demonstrations for $skillName exercises');
        recommendations.add('Simplify instructions into clear, manageable steps');
      }

      // Skill-specific recommendations
      switch (skillName.toLowerCase()) {
        case 'walking':
          if (avgPerformance <= 5) {
            recommendations.addAll([
              'Practice walking in straight lines with supervision',
              'Use floor markers as guides for proper foot placement',
              'Include balance exercises in daily routine'
            ]);
          }
          break;
        
        case 'running':
          if (avgPerformance <= 5) {
            recommendations.addAll([
              'Practice coordinating arm and leg movements while running',
              'Focus on maintaining proper posture',
              'Include short distance running exercises'
            ]);
          }
          break;

        case 'jumping':
          if (avgPerformance <= 5) {
            recommendations.addAll([
              'Practice landing safely with bent knees',
              'Start with small jumps and gradually increase height',
              'Work on balance exercises before and after jumping'
            ]);
          }
          break;

        case 'throwing':
          if (avgPerformance <= 5) {
            recommendations.addAll([
              'Practice proper ball grip techniques',
              'Work on arm positioning and movement',
              'Start with soft balls and short distances'
            ]);
          }
          break;

        case 'kicking':
          if (avgPerformance <= 5) {
            recommendations.addAll([
              'Practice proper foot positioning',
              'Work on balance while kicking',
              'Use stationary balls for initial practice'
            ]);
          }
          break;
      }
    });

    return recommendations.isNotEmpty ? recommendations : ['Continue with regular practice sessions'];
  }
}