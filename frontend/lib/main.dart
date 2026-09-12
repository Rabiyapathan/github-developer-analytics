import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const GitHubAnalyticsApp());
}

class GitHubAnalyticsApp extends StatelessWidget {
  const GitHubAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GitHub Developer Analytics',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF58A6FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GitHubHomePage(),
    );
  }
}

class GitHubHomePage extends StatefulWidget {
  const GitHubHomePage({super.key});

  @override
  State<GitHubHomePage> createState() => _GitHubHomePageState();
}

class _GitHubHomePageState extends State<GitHubHomePage> {
  final TextEditingController usernameController =
      TextEditingController();

  // All backend requests use this one base URL.
  static const String backendBaseUrl = 'http://127.0.0.1:5000';

  Map<String, dynamic>? developerData;
  Map<String, dynamic>? repositoryData;

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  Future<void> analyzeDeveloper() async {
    final username = usernameController.text.trim();

    if (username.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a GitHub username.';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      errorMessage = null;
      developerData = null;
      repositoryData = null;
    });

    try {
      final profileUrl = Uri.parse(
        '$backendBaseUrl/api/github/$username',
      );

      final repositoryUrl = Uri.parse(
        '$backendBaseUrl/api/github/$username/repositories',
      );

      final profileResponse = await http.get(profileUrl);

      if (profileResponse.statusCode == 404) {
        setState(() {
          errorMessage = 'GitHub user "$username" was not found.';
          isLoading = false;
        });
        return;
      }

      if (profileResponse.statusCode != 200) {
        setState(() {
          errorMessage =
              'Unable to load the GitHub profile right now.';
          isLoading = false;
        });
        return;
      }

      final repositoryResponse = await http.get(repositoryUrl);

      if (repositoryResponse.statusCode != 200) {
        setState(() {
          errorMessage =
              'Profile loaded, but repository analytics could not be retrieved.';
          isLoading = false;
        });
        return;
      }

      final profileData =
          jsonDecode(profileResponse.body) as Map<String, dynamic>;

      final repositories =
          jsonDecode(repositoryResponse.body)
              as Map<String, dynamic>;

      if (!mounted) return;

      setState(() {
        developerData = profileData;
        repositoryData = repositories;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Could not connect to the backend.\n'
            'Make sure Flask is running on port 5000.';
        isLoading = false;
      });
    }
  }

  void clearResults() {
    setState(() {
      developerData = null;
      repositoryData = null;
      errorMessage = null;
      usernameController.clear();
    });
  }

  Widget buildStatCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        color: const Color(0xFF161B22),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: Color(0xFF30363D),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: const Color(0xFF58A6FF),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      color: const Color(0xFF161B22),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFF30363D),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF58A6FF),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDeveloperProfile() {
    if (developerData == null) {
      return const SizedBox.shrink();
    }

    final name =
        developerData!['name'] ?? 'Unknown Developer';

    final username =
        developerData!['username'] ?? '';

    final followers =
        developerData!['followers']?.toString() ?? '0';

    final following =
        developerData!['following']?.toString() ?? '0';

    final repositories =
        developerData!['public_repositories']?.toString() ?? '0';

    return Card(
      color: const Color(0xFF161B22),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0xFF30363D),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 42,
              backgroundColor: Color(0xFF238636),
              child: Icon(
                Icons.person,
                size: 44,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '@$username',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 28),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 500) {
                  return Column(
                    children: [
                      buildMobileStatCard(
                        'Repositories',
                        repositories,
                        Icons.folder_outlined,
                      ),
                      const SizedBox(height: 10),
                      buildMobileStatCard(
                        'Followers',
                        followers,
                        Icons.people_outline,
                      ),
                      const SizedBox(height: 10),
                      buildMobileStatCard(
                        'Following',
                        following,
                        Icons.person_add_outlined,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    buildStatCard(
                      'Repositories',
                      repositories,
                      Icons.folder_outlined,
                    ),
                    const SizedBox(width: 12),
                    buildStatCard(
                      'Followers',
                      followers,
                      Icons.people_outline,
                    ),
                    const SizedBox(width: 12),
                    buildStatCard(
                      'Following',
                      following,
                      Icons.person_add_outlined,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMobileStatCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      color: const Color(0xFF0D1117),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF58A6FF),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRepositoryAnalytics() {
    if (repositoryData == null) {
      return const SizedBox.shrink();
    }

    final totalRepositories =
        repositoryData!['total_repositories']?.toString() ?? '0';

    final totalStars =
        repositoryData!['total_stars']?.toString() ?? '0';

    final totalForks =
        repositoryData!['total_forks']?.toString() ?? '0';

    final totalOpenIssues =
        repositoryData!['total_open_issues']?.toString() ?? '0';

    final languages = Map<String, dynamic>.from(
      repositoryData!['languages'] ?? {},
    );

    final mostStarred =
        repositoryData!['most_starred_repository'];

    final recentRepositories = List<dynamic>.from(
      repositoryData!['recent_repositories'] ?? [],
    );

    final repositories = List<dynamic>.from(
      repositoryData!['repositories'] ?? [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 35),

        const Text(
          'Repository Analytics',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 18),

        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  buildAnalyticsCard(
                    'Total Repositories',
                    totalRepositories,
                    Icons.folder_copy_outlined,
                  ),
                  const SizedBox(height: 12),
                  buildAnalyticsCard(
                    'Total Stars',
                    totalStars,
                    Icons.star_outline,
                  ),
                  const SizedBox(height: 12),
                  buildAnalyticsCard(
                    'Total Forks',
                    totalForks,
                    Icons.call_split_outlined,
                  ),
                  const SizedBox(height: 12),
                  buildAnalyticsCard(
                    'Open Issues',
                    totalOpenIssues,
                    Icons.bug_report_outlined,
                  ),
                ],
              );
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: buildAnalyticsCard(
                        'Total Repositories',
                        totalRepositories,
                        Icons.folder_copy_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildAnalyticsCard(
                        'Total Stars',
                        totalStars,
                        Icons.star_outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: buildAnalyticsCard(
                        'Total Forks',
                        totalForks,
                        Icons.call_split_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildAnalyticsCard(
                        'Open Issues',
                        totalOpenIssues,
                        Icons.bug_report_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 25),

        buildMostStarredCard(mostStarred),

        const SizedBox(height: 18),

        buildLanguagesCard(languages),

        const SizedBox(height: 18),

        buildRecentRepositoriesCard(recentRepositories),

        const SizedBox(height: 18),

        buildRepositoriesCard(repositories),
      ],
    );
  }

  Widget buildMostStarredCard(dynamic mostStarred) {
    return Card(
      color: const Color(0xFF161B22),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFF30363D),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏆 Most Starred Repository',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            if (mostStarred == null)
              const Text(
                'No repository data available.',
                style: TextStyle(
                  color: Colors.white60,
                ),
              )
            else ...[
              Text(
                mostStarred['name'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 20,
                    color: Color(0xFFFFC107),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${mostStarred['stars'] ?? 0} stars',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildLanguagesCard(
    Map<String, dynamic> languages,
  ) {
    return Card(
      color: const Color(0xFF161B22),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFF30363D),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💻 Languages',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            if (languages.isEmpty)
              const Text(
                'No language data available.',
                style: TextStyle(
                  color: Colors.white60,
                ),
              )
            else
              ...languages.entries.map(
                (entry) {
                  final count =
                      int.tryParse(
                            entry.value.toString(),
                          ) ??
                          0;

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              '$count repo${count == 1 ? '' : 's'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: count /
                                languages.values
                                    .fold<int>(
                                      0,
                                      (sum, value) =>
                                          sum +
                                          (int.tryParse(
                                                value
                                                    .toString(),
                                              ) ??
                                              0),
                                    ),
                            minHeight: 7,
                            backgroundColor:
                                const Color(0xFF21262D),
                            valueColor:
                                const AlwaysStoppedAnimation<
                                    Color>(
                              Color(0xFF58A6FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget buildRecentRepositoriesCard(
    List<dynamic> recentRepositories,
  ) {
    return Card(
      color: const Color(0xFF161B22),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFF30363D),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🕐 Recently Updated',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            if (recentRepositories.isEmpty)
              const Text(
                'No recent repositories found.',
                style: TextStyle(
                  color: Colors.white60,
                ),
              )
            else
              ...recentRepositories.map(
                (repo) {
                  final name =
                      repo['name'] ?? 'Unknown';

                  final updatedAt =
                      repo['updated_at'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1117),
                      borderRadius:
                          BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF21262D),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.update,
                          color: Color(0xFF58A6FF),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatDate(updatedAt),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget buildRepositoriesCard(
    List<dynamic> repositories,
  ) {
    return Card(
      color: const Color(0xFF161B22),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFF30363D),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📁 Repositories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            if (repositories.isEmpty)
              const Text(
                'This developer has no public repositories.',
                style: TextStyle(
                  color: Colors.white60,
                ),
              )
            else
              ...repositories.map(
                (repo) {
                  final name =
                      repo['name'] ?? 'Unknown';

                  final language =
                      repo['language'] ?? 'Unknown';

                  final stars =
                      repo['stars'] ?? 0;

                  final forks =
                      repo['forks'] ?? 0;

                  final issues =
                      repo['open_issues'] ?? 0;

                  return Container(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1117),
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF21262D),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF58A6FF),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 18,
                          runSpacing: 8,
                          children: [
                            buildRepositoryInfo(
                              Icons.code,
                              language.toString(),
                            ),
                            buildRepositoryInfo(
                              Icons.star_outline,
                              '$stars stars',
                            ),
                            buildRepositoryInfo(
                              Icons.call_split_outlined,
                              '$forks forks',
                            ),
                            buildRepositoryInfo(
                              Icons.bug_report_outlined,
                              '$issues issues',
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget buildRepositoryInfo(
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white54,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  String formatDate(String value) {
    if (value.isEmpty) {
      return 'Unknown update time';
    }

    try {
      final date = DateTime.parse(value).toLocal();

      const months = [
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

      return 'Updated ${months[date.month - 1]} '
          '${date.day}, ${date.year}';
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 850,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.insights,
                    size: 72,
                    color: Color(0xFF58A6FF),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'GitHub Developer Analytics',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Turn GitHub activity into meaningful developer insights.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 48),

                  TextField(
                    controller: usernameController,
                    onSubmitted: (_) => analyzeDeveloper(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Enter GitHub username',
                      prefixIcon: const Icon(
                        Icons.person_outline,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF161B22),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF58A6FF),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : analyzeDeveloper,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .analytics_outlined,
                                  ),
                            label: Text(
                              isLoading
                                  ? 'Analyzing...'
                                  : 'Analyze Developer',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (developerData != null) ...[
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 54,
                          child: OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : clearResults,
                            child: const Text('New Search'),
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D1616),
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF85149),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFF85149),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (developerData != null) ...[
                    const SizedBox(height: 40),
                    buildDeveloperProfile(),
                    buildRepositoryAnalytics(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}