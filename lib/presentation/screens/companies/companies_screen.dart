import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/services/api_config.dart';
import '../../../data/models/company_model.dart';
import '../../../providers/companies_provider.dart';
import '../../widgets/app_drawer.dart';
import '../company_detail/company_detail_screen.dart';

class CompaniesScreen extends StatefulWidget {
  static const routeName = '/companies';

  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompaniesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.companies),
      ),
      drawer: const AppDrawer(),
      body: _CompaniesBody(
        provider: provider,
        controller: _searchController,
      ),
    );
  }
}

class _CompaniesBody extends StatelessWidget {
  const _CompaniesBody({required this.provider, required this.controller});

  final CompaniesProvider provider;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.companies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.companies.isEmpty) {
      return _ErrorView(
        message: provider.errorMessage!,
        onRetry: provider.refreshCompanies,
      );
    }

    if (provider.companies.isEmpty) {
      return RefreshIndicator(
        onRefresh: provider.refreshCompanies,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SearchField(
              controller: controller,
              onSearch: provider.searchCompanies,
              isLoading: provider.isLoading,
            ),
            const SizedBox(height: 16),
            const _EmptyView(
              message: 'No companies found. Try searching for another studio.',
            ),
          ],
        ),
      );
    }

    final itemCount = 1 + provider.companies.length + (provider.isLoadingMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: provider.refreshCompanies,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          final shouldLoadMore =
              metrics.pixels >= metrics.maxScrollExtent - 200 &&
                  provider.canLoadMore &&
                  !provider.isLoadingMore &&
                  !provider.isLoading;

          if (shouldLoadMore) {
            provider.loadMoreCompanies();
          }

          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _SearchField(
                controller: controller,
                onSearch: provider.searchCompanies,
                isLoading: provider.isLoading,
              );
            }

            final dataIndex = index - 1;

            if (dataIndex >= provider.companies.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final company = provider.companies[dataIndex];
            return _CompanyCard(company: company);
          },
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onSearch,
    required this.isLoading,
  });

  final TextEditingController controller;
  final Future<void> Function(String) onSearch;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: 'Search companies',
        hintText: 'e.g. Studio Ghibli',
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => onSearch(controller.text),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onSubmitted: onSearch,
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    final logoUrl = ApiConfig.getLogoUrl(company.logoPath);
    final subtitleParts = <String>[];
    if (company.originCountry != null && company.originCountry!.isNotEmpty) {
      subtitleParts.add(company.originCountry!);
    }
    if (company.homepage != null && company.homepage!.isNotEmpty) {
      subtitleParts.add(company.homepage!);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            CompanyDetailScreen.routeName,
            arguments: company,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: logoUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: logoUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.business_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : Icon(
                            Icons.business_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitleParts.join(' • '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                (company.description?.isNotEmpty ?? false)
                    ? company.description!
                    : 'No description available.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
