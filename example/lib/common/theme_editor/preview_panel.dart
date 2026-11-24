import 'package:finesse/finesse.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart'
    hide
        Badge,
        Card,
        Checkbox,
        Dialog,
        Divider,
        IconButton,
        Radio,
        Slider,
        Switch,
        Tab,
        TextField,
        Theme,
        Tooltip,
        showDialog;

/// The live-themed half of the theme editor.
///
/// Modelled on shadcn/ui's `/create` preview: a masonry of realistic product
/// cards rather than a component gallery, so a configuration can be judged the
/// way it will actually be seen. Charts are drawn with `fl_chart` and take
/// their colours from `ColorScheme.charts`, which is what makes the
/// editor's "Chart Color" setting visible.
class ThemePreviewPanel extends StatelessWidget {
  const ThemePreviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.muted,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Column count follows the available width, the way the reference
            // reflows its cards.
            // Cards carry dense rows (icon + label + date + amount), so a
            // column narrower than ~360px starts clipping them.
            final columns = switch (constraints.maxWidth) {
              < 800 => 1,
              < 1240 => 2,
              _ => 3,
            };
            return _Masonry(
              columns: columns,
              spacing: 16,
              children: const [
                _ContributionHistoryCard(),
                _WireTransferCard(),
                _PayoutThresholdCard(),
                _SavingsTargetsCard(),
                _ClaimableBalanceCard(),
                _RecentTransactionsCard(),
                _BuyInvestmentCard(),
                _DistributeTrackCard(),
                _TeamActivityCard(),
                _PaletteCard(),
                _TypographyCard(),
                _NotificationsCard(),
                _VerifyDeviceCard(),
                _ScheduleCard(),
                _QuickActionsCard(),
                _WorkspaceCard(),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A simple column-balancing masonry: each child goes to the shortest column.
///
/// Cards have very different heights, so a uniform grid would leave large
/// gaps.
class _Masonry extends StatelessWidget {
  const _Masonry({
    required this.columns,
    required this.children,
    this.spacing = 16,
  });

  final int columns;
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final buckets = List.generate(columns, (_) => <Widget>[]);
    for (var i = 0; i < children.length; i++) {
      buckets[i % columns].add(children[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < columns; c++) ...[
          if (c > 0) SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < buckets[c].length; i++) ...[
                  if (i > 0) SizedBox(height: spacing),
                  buckets[c][i],
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// A card with the header shape the reference uses: title, optional
/// description, optional trailing action.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.child,
    this.title,
    this.description,
    this.trailing,
  });

  final String? title;
  final String? description;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Deliberately Card's own title/description slots rather than hand-set
    // text styles: that is what puts the card under the theme's typography, so
    // switching style visibly retypes the preview.
    return Card(
      title: title == null ? null : Text(title!),
      description: description == null ? null : Text(description!),
      action: trailing,
      child: child,
    );
  }
}

class _ContributionHistoryCard extends StatelessWidget {
  const _ContributionHistoryCard();

  static const _months = ['Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May'];
  static const _values = [42.0, 58.0, 46.0, 74.0, 38.0, 82.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewCard(
      title: 'Contribution History',
      description: 'Last 6 months of activity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _months[value.toInt() % _months.length],
                          style: theme.textTheme.muted.copyWith(fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < _values.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: _values[i],
                          // Cycles the themed ramp so the Chart Color setting
                          // is immediately visible.
                          color: theme.colorScheme.charts[i % 5],
                          width: 22,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(theme.radius.topLeft.x),
                            topRight: Radius.circular(theme.radius.topLeft.x),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'UPCOMING',
                  value: 'May 25, 2024',
                  caption: r'$1,000 scheduled',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _Stat(
                  label: 'AUTO-SAVE PLAN',
                  value: 'Accelerated',
                  caption: 'Recurring weekly',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Button.secondary(
            onPressed: () {},
            child: const Text('View Full Report'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: theme.radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.muted.copyWith(
              fontSize: 10,
              letterSpacing: .6,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.large),
          Text(caption, style: theme.textTheme.muted),
        ],
      ),
    );
  }
}

class _PayoutThresholdCard extends StatefulWidget {
  const _PayoutThresholdCard();

  @override
  State<_PayoutThresholdCard> createState() => _PayoutThresholdCardState();
}

class _PayoutThresholdCardState extends State<_PayoutThresholdCard> {
  double amount = 2500;
  String currency = 'usd';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewCard(
      title: 'Payout Threshold',
      description: 'Set the minimum balance required before a payout.',
      trailing: IconButton.ghost(
        icon: const Icon(LucideIcons.x),
        semanticLabel: 'Dismiss',
        onPressed: () {},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Preferred Currency', style: theme.textTheme.small),
          const SizedBox(height: 6),
          Select<String>(
            initialValue: currency,
            onChanged: (v) => setState(() => currency = v ?? currency),
            options: const [
              SelectOption(
                value: 'usd',
                child: Text('USD — United States Dollar'),
              ),
              SelectOption(value: 'eur', child: Text('EUR — Euro')),
              SelectOption(value: 'gbp', child: Text('GBP — British Pound')),
              SelectOption(value: 'sek', child: Text('SEK — Swedish Krona')),
            ],
            selectedOptionBuilder: (context, value) => Text(
              switch (value) {
                'usd' => 'USD — United States Dollar',
                'eur' => 'EUR — Euro',
                'gbp' => 'GBP — British Pound',
                _ => 'SEK — Swedish Krona',
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Minimum Payout Amount',
                  style: theme.textTheme.small,
                ),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: theme.textTheme.h4,
              ),
            ],
          ),
          Slider(
            initialValue: amount,
            min: 50,
            max: 10000,
            onChanged: (v) => setState(() => amount = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(r'$50 (MIN)', style: theme.textTheme.muted),
              Text(r'$10,000 (MAX)', style: theme.textTheme.muted),
            ],
          ),
          const SizedBox(height: 16),
          Text('Notes', style: theme.textTheme.small),
          const SizedBox(height: 6),
          const Textarea(
            placeholder: Text('Add any notes for this payout configuration...'),
          ),
          const SizedBox(height: 16),
          Button(
            onPressed: () {},
            child: const Text('Save Threshold'),
          ),
        ],
      ),
    );
  }
}

class _SavingsTargetsCard extends StatelessWidget {
  const _SavingsTargetsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewCard(
      title: 'Savings Targets',
      description: 'Active milestones for 2024',
      trailing: Button.outline(
        size: ButtonSize.sm,
        onPressed: () {},
        child: const Text('New Goal'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Target(
            label: 'RETIREMENT',
            amount: r'$420,000',
            progress: .65,
            achieved: r'$273,000',
            chartIndex: 0,
          ),
          const SizedBox(height: 12),
          const _Target(
            label: 'REAL ESTATE',
            amount: r'$85,000',
            progress: .32,
            achieved: r'$27,200',
            chartIndex: 2,
          ),
          const SizedBox(height: 12),
          Text(
            'You have not met your targets for this year.',
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}

class _Target extends StatelessWidget {
  const _Target({
    required this.label,
    required this.amount,
    required this.progress,
    required this.achieved,
    required this.chartIndex,
  });

  final String label;
  final String amount;
  final double progress;
  final String achieved;
  final int chartIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        borderRadius: theme.radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.muted.copyWith(
              fontSize: 10,
              letterSpacing: .6,
            ),
          ),
          const SizedBox(height: 2),
          Text(amount, style: theme.textTheme.h3),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.colorScheme.border,
              valueColor: AlwaysStoppedAnimation(
                theme.colorScheme.charts[chartIndex],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${(progress * 100).round()}% achieved',
                  style: theme.textTheme.muted,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(achieved, style: theme.textTheme.small),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClaimableBalanceCard extends StatelessWidget {
  const _ClaimableBalanceCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewCard(
      title: 'Claimable Balance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(r'$0.00', style: theme.textTheme.h1),
          const SizedBox(height: 8),
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: Badge.secondary(child: Text('Pending Setup')),
          ),
          const SizedBox(height: 16),
          const _Row(label: 'Net Royalties', value: r'$0.00'),
          const _Row(label: 'Processing Fee', value: r'-$0.00'),
          const Divider.horizontal(
            margin: EdgeInsets.symmetric(vertical: 8),
          ),
          const _Row(label: 'Total Ready to Claim', value: r'$0.00 USD'),
          const SizedBox(height: 16),
          Text(
            'Once your bank is connected, balances over \$10.00 are '
            'automatically eligible for monthly distribution.',
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.small,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: theme.textTheme.small),
        ],
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard();

  static const _dateWidth = 120.0;
  static const _amountWidth = 88.0;

  static const _items = [
    (
      LucideIcons.coffee,
      'Blue Bottle Coffee',
      'Food & Drink',
      'Today, 10:24 AM',
      r'-$8.50',
    ),
    (
      LucideIcons.shoppingCart,
      'Whole Foods Market',
      'Groceries',
      'Yesterday',
      r'-$126.40',
    ),
    (
      LucideIcons.creditCard,
      'Stripe Payout',
      'Income',
      'Oct 12',
      r'+$4,200.00',
    ),
    (LucideIcons.car, 'Uber Technologies', 'Transport', 'Oct 11', r'-$24.10'),
    (
      LucideIcons.tv,
      'Netflix Subscription',
      'Entertainment',
      'Oct 10',
      r'-$15.99',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewCard(
      title: 'Recent Transactions',
      description: 'Your latest account activity.',
      child: Column(
        children: [
          for (final (icon, name, category, date, amount) in _items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.muted,
                      borderRadius: theme.radius,
                    ),
                    child: Icon(icon, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.small,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(category, style: theme.textTheme.muted),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: _dateWidth,
                    child: Text(
                      date,
                      style: theme.textTheme.muted,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: _amountWidth,
                    child: Text(
                      amount,
                      style: theme.textTheme.small.copyWith(
                        color: amount.startsWith('+')
                            ? theme.colorScheme.charts[1]
                            : null,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BuyInvestmentCard extends StatefulWidget {
  const _BuyInvestmentCard();

  @override
  State<_BuyInvestmentCard> createState() => _BuyInvestmentCardState();
}

class _BuyInvestmentCardState extends State<_BuyInvestmentCard> {
  String orderType = 'market';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewCard(
      title: 'Buy Investment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Amount to Invest', style: theme.textTheme.small),
          const SizedBox(height: 6),
          const TextField(
            initialValue: '1,000.00',
            leading: Padding(
              padding: EdgeInsets.only(right: 4),
              child: Text(r'$'),
            ),
          ),
          const SizedBox(height: 12),
          Text('Order Type', style: theme.textTheme.small),
          const SizedBox(height: 6),
          Select<String>(
            initialValue: orderType,
            onChanged: (v) => setState(() => orderType = v ?? orderType),
            options: const [
              SelectOption(value: 'market', child: Text('Market Order')),
              SelectOption(value: 'limit', child: Text('Limit Order')),
              SelectOption(value: 'stop', child: Text('Stop Order')),
            ],
            selectedOptionBuilder: (context, value) => Text(
              switch (value) {
                'market' => 'Market Order',
                'limit' => 'Limit Order',
                _ => 'Stop Order',
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Market orders execute at the current price.',
            style: theme.textTheme.muted,
          ),
          const SizedBox(height: 12),
          const _Row(label: 'Estimated Shares', value: '12.48'),
          const _Row(label: 'Buying Power', value: r'$8,420.00'),
          const SizedBox(height: 16),
          Button(onPressed: () {}, child: const Text('Review Order')),
          const SizedBox(height: 8),
          Text(
            'Trades are typically executed within market hours.',
            style: theme.textTheme.muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// A field, a select and a button share one row here on purpose: the
/// reference gives all three the same border-box height per style, so any
/// regression in a control's height shows up immediately as a ragged row.
class _WireTransferCard extends StatefulWidget {
  const _WireTransferCard();

  @override
  State<_WireTransferCard> createState() => _WireTransferCardState();
}

class _WireTransferCardState extends State<_WireTransferCard> {
  String currency = 'usd';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewCard(
      title: 'Wire Transfer',
      description: 'Same-day settlement to any linked account.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: TextField(placeholder: Text('Amount')),
              ),
              const SizedBox(width: 8),
              Select<String>(
                minWidth: 96,
                initialValue: currency,
                onChanged: (v) => setState(() => currency = v ?? currency),
                options: const [
                  SelectOption(value: 'usd', child: Text('USD')),
                  SelectOption(value: 'eur', child: Text('EUR')),
                  SelectOption(value: 'sek', child: Text('SEK')),
                ],
                selectedOptionBuilder: (context, value) =>
                    Text(value.toUpperCase()),
              ),
              const SizedBox(width: 8),
              Button(onPressed: () {}, child: const Text('Send')),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fees are waived for transfers over \$1,000.',
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}

class _DistributeTrackCard extends StatelessWidget {
  const _DistributeTrackCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewCard(
      child: Empty(
        icon: const Icon(LucideIcons.plus),
        title: const Text('Distribute Track'),
        description: const Text(
          'Upload your first master to start reaching listeners on Spotify, '
          'Apple Music, and more.',
        ),
        actions: [
          Button(onPressed: () {}, child: const Text('Create Release')),
        ],
        // The reference Empty keeps its `p-12` breathing room, which is what
        // centres the block inside the card; zeroing it pinned the icon to
        // the top edge.
        padding: const EdgeInsets.symmetric(vertical: 24),
        titleStyle: theme.textTheme.large,
      ),
    );
  }
}

class _TeamActivityCard extends StatefulWidget {
  const _TeamActivityCard();

  @override
  State<_TeamActivityCard> createState() => _TeamActivityCardState();
}

class _TeamActivityCardState extends State<_TeamActivityCard> {
  final tabs = TabsController<String>(value: 'overview');
  bool notify = true;
  Set<String> range = {'30d'};

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewCard(
      title: 'Team Activity',
      description: 'Engagement over the selected range.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToggleGroup<String>(
            values: range,
            onChanged: (v) => setState(() => range = v),
            children: const [
              ToggleGroupItem(value: '7d', child: Text('7d')),
              ToggleGroupItem(value: '30d', child: Text('30d')),
              ToggleGroupItem(value: '90d', child: Text('90d')),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                titlesData: const FlTitlesData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: theme.colorScheme.border,
                    strokeWidth: 1,
                  ),
                ),
                lineBarsData: [
                  for (var series = 0; series < 2; series++)
                    LineChartBarData(
                      isCurved: true,
                      color: theme.colorScheme.charts[series * 2],
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.charts[series * 2].withValues(
                          alpha: .12,
                        ),
                      ),
                      spots: [
                        for (var i = 0; i < 7; i++)
                          FlSpot(
                            i.toDouble(),
                            [30.0, 52, 44, 68, 58, 80, 72][i] - (series * 18),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Switch(
            value: notify,
            label: const Text('Email me weekly summaries'),
            onChanged: (v) => setState(() => notify = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Avatar(
                'https://avatars.githubusercontent.com/u/124599?v=4',
                fallback: Text('CN'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Shared with 4 teammates',
                  style: theme.textTheme.muted,
                ),
              ),
              Button.ghost(
                size: ButtonSize.sm,
                onPressed: () {},
                child: const Text('Manage'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Selection controls: checkbox, radio group, switch.
///
/// The reference's preview has a settings card for exactly this reason — these
/// are the components where a style's radius and focus ring read most clearly.
class _NotificationsCard extends StatefulWidget {
  const _NotificationsCard();

  @override
  State<_NotificationsCard> createState() => _NotificationsCardState();
}

enum _NotifyAbout { all, mentions, none }

class _NotificationsCardState extends State<_NotificationsCard> {
  _NotifyAbout about = _NotifyAbout.mentions;
  final channels = {'Email': true, 'Push': true, 'SMS': false};
  bool marketing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewCard(
      title: 'Notifications',
      description: 'Choose what you want to be notified about',
      child: FinesseColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          FinesseRadioGroup<_NotifyAbout>(
            initialValue: about,
            onChanged: (v) => setState(() => about = v ?? about),
            items: const [
              Radio(
                value: _NotifyAbout.all,
                label: Text('All new messages'),
              ),
              Radio(
                value: _NotifyAbout.mentions,
                label: Text('Direct messages and mentions'),
              ),
              Radio(value: _NotifyAbout.none, label: Text('Nothing')),
            ],
          ),
          const Divider.horizontal(
            margin: EdgeInsets.symmetric(
              vertical: 4,
            ),
          ),
          for (final entry in channels.entries)
            Checkbox(
              value: entry.value,
              onChanged: (v) => setState(() => channels[entry.key] = v),
              label: Text(entry.key),
            ),
          const Divider.horizontal(
            margin: EdgeInsets.symmetric(
              vertical: 4,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Product updates',
                  style: theme.textTheme.small,
                ),
              ),
              Switch(
                value: marketing,
                onChanged: (v) => setState(() => marketing = v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A verification flow: OTP input, progress, tooltip, keyboard hint, alert.
class _VerifyDeviceCard extends StatefulWidget {
  const _VerifyDeviceCard();

  @override
  State<_VerifyDeviceCard> createState() => _VerifyDeviceCardState();
}

class _VerifyDeviceCardState extends State<_VerifyDeviceCard> {
  String code = '';
  bool submitting = false;

  Future<void> submit() async {
    setState(() => submitting = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewCard(
      title: 'Verify Device',
      description: 'Enter the 6-digit code we sent you',
      trailing: Tooltip(
        builder: (_) => const Text('Resend the code'),
        child: IconButton.ghost(
          icon: const Icon(LucideIcons.refreshCw, size: 16),
          onPressed: () {},
        ),
      ),
      child: FinesseColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          OtpField(
            maxLength: 6,
            onChanged: (v) => setState(() => code = v),
            children: const [
              OtpFieldGroup(
                children: [
                  OtpFieldSlot(),
                  OtpFieldSlot(),
                  OtpFieldSlot(),
                ],
              ),
              Icon(LucideIcons.dot),
              OtpFieldGroup(
                children: [
                  OtpFieldSlot(),
                  OtpFieldSlot(),
                  OtpFieldSlot(),
                ],
              ),
            ],
          ),
          ProgressBar(value: code.length / 6),
          FinesseRow(
            spacing: 2,
            children: [
              Text('Paste with', style: theme.textTheme.muted),
              const Kbd.group(['⌘', 'V']),
            ],
          ),
          const Alert(
            icon: Icon(LucideIcons.info),
            title: Text('Heads up'),
            description: Text('Codes expire after 10 minutes.'),
          ),
          Button(
            onPressed: submitting ? null : submit,
            leading: submitting
                ? const Spinner(size: 16, strokeWidth: 2)
                : null,
            child: Text(submitting ? 'Verifying' : 'Verify'),
          ),
        ],
      ),
    );
  }
}

/// Scheduling: breadcrumb, date and time pickers, an accordion, a collapsible.
class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewCard(
      title: 'Schedule Payout',
      description: 'Pick when the transfer should run',
      child: FinesseColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Breadcrumb(
            children: [
              BreadcrumbLink(onPressed: () {}, child: const Text('Wallet')),
              const BreadcrumbEllipsis(),
              const Text('Payouts'),
            ],
          ),
          const DatePicker(),
          const TimePicker(),
          Accordion<int>(
            children: [
              AccordionItem(
                value: 0,
                title: const Text('When will it arrive?'),
                child: Text(
                  'Transfers settle in 1-2 business days.',
                  style: theme.textTheme.muted,
                ),
              ),
              AccordionItem(
                value: 1,
                title: const Text('Are there fees?'),
                child: Text(
                  'Standard transfers are free.',
                  style: theme.textTheme.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The overlay family — popover, dialog, sheet, context menu, toast — plus the
/// loading placeholders, all of which are themed surfaces worth previewing.
class _QuickActionsCard extends StatefulWidget {
  const _QuickActionsCard();

  @override
  State<_QuickActionsCard> createState() => _QuickActionsCardState();
}

class _QuickActionsCardState extends State<_QuickActionsCard> {
  final popover = PopoverController();
  int page = 2;

  @override
  void dispose() {
    popover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewCard(
      title: 'Quick Actions',
      description: 'Every themed surface in one place',
      child: FinesseColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Popover(
                controller: popover,
                popover: (_) => SizedBox(
                  width: 220,
                  child: FinesseColumn(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 1,
                    children: [
                      Text('Dimensions', style: theme.textTheme.small),
                      Text(
                        'Set the layer dimensions.',
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                ),
                child: Button.outline(
                  onPressed: popover.toggle,
                  child: const Text('Popover'),
                ),
              ),
              Button.outline(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => Dialog.alert(
                    title: const Text('Are you sure?'),
                    description: const Text(
                      'This will permanently cancel the scheduled payout.',
                    ),
                    actions: [
                      Button.outline(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      Button(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                ),
                child: const Text('Dialog'),
              ),
              Button.outline(
                onPressed: () => showSheet<void>(
                  context: context,
                  builder: (context) => Sheet(
                    title: const Text('Filters'),
                    description: const Text('Narrow the transaction list.'),
                    child: const SizedBox(height: 80),
                  ),
                ),
                child: const Text('Sheet'),
              ),
              Button.outline(
                onPressed: () => Sonner.of(context).show(
                  const Toast(
                    title: Text('Payout scheduled'),
                    description: Text('Friday at 09:00'),
                  ),
                ),
                child: const Text('Toast'),
              ),
            ],
          ),
          const Divider.horizontal(
            margin: EdgeInsets.symmetric(
              vertical: 4,
            ),
          ),
          // Right-click target: the context menu is a themed surface too.
          ContextMenuRegion(
            constraints: const BoxConstraints(minWidth: 200),
            items: const [
              ContextMenuItem(child: Text('Duplicate')),
              ContextMenuItem(child: Text('Archive')),
              ContextMenuItem(enabled: false, child: Text('Delete')),
            ],
            child: Card(
              child: FinesseRow(
                spacing: 2,
                children: [
                  const Icon(LucideIcons.mousePointerClick, size: 16),
                  Expanded(
                    child: Text(
                      'Right-click for options',
                      style: theme.textTheme.small,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider.horizontal(
            margin: EdgeInsets.symmetric(
              vertical: 4,
            ),
          ),
          // The loading state of the row above it, so skeletons are themed
          // against the same surface they stand in for.
          FinesseRow(
            spacing: 3,
            children: const [
              Skeleton(width: 36, height: 36),
              Expanded(
                child: FinesseColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Skeleton(width: 140, height: 12),
                    Skeleton(width: 90, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const Divider.horizontal(
            margin: EdgeInsets.symmetric(
              vertical: 4,
            ),
          ),
          PaginationCompact(
            page: page,
            pageCount: 8,
            onPageChanged: (p) => setState(() => page = p),
          ),
        ],
      ),
    );
  }
}

/// A workspace pane: menubar, tabs, a table, toggles, a command palette and a
/// resizable split — the structural components the other cards don't reach.
class _WorkspaceCard extends StatefulWidget {
  const _WorkspaceCard();

  @override
  State<_WorkspaceCard> createState() => _WorkspaceCardState();
}

class _WorkspaceCardState extends State<_WorkspaceCard> {
  static const _rows = [
    ('INV-001', 'Paid', r'$250.00'),
    ('INV-002', 'Pending', r'$150.00'),
    ('INV-003', 'Unpaid', r'$350.00'),
  ];

  bool bold = true;
  bool italic = false;
  final collapsible = CollapsibleController(open: true);

  @override
  void dispose() {
    collapsible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewCard(
      title: 'Workspace',
      description: 'Invoices for the current period',
      child: FinesseColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Menubar(
            items: [
              MenubarItem(
                items: const [
                  ContextMenuItem(child: Text('New Invoice')),
                  ContextMenuItem(child: Text('Import…')),
                  ContextMenuItem(
                    trailing: Icon(LucideIcons.chevronRight),
                    items: [
                      ContextMenuItem(child: Text('INV-001')),
                      ContextMenuItem(child: Text('INV-002')),
                      ContextMenuItem(child: Text('INV-003')),
                    ],
                    child: Text('Open Recent'),
                  ),
                  ContextMenuItem(
                    trailing: Icon(LucideIcons.chevronRight),
                    items: [
                      ContextMenuItem(child: Text('PDF')),
                      ContextMenuItem(child: Text('CSV')),
                      ContextMenuItem(
                        trailing: Icon(LucideIcons.chevronRight),
                        items: [
                          ContextMenuItem(child: Text('Xero')),
                          ContextMenuItem(child: Text('QuickBooks')),
                        ],
                        child: Text('Accounting'),
                      ),
                    ],
                    child: Text('Export As'),
                  ),
                  ContextMenuItem(
                    trailing: Icon(LucideIcons.chevronRight),
                    items: [
                      ContextMenuItem(child: Text('Email')),
                      ContextMenuItem(child: Text('Copy Link')),
                    ],
                    child: Text('Share'),
                  ),
                ],
                child: const Text('File'),
              ),
              MenubarItem(
                items: const [
                  ContextMenuItem(child: Text('Undo')),
                  ContextMenuItem(child: Text('Redo')),
                  ContextMenuItem(
                    trailing: Icon(LucideIcons.chevronRight),
                    items: [
                      ContextMenuItem(child: Text('Find…')),
                      ContextMenuItem(child: Text('Find Next')),
                      ContextMenuItem(child: Text('Find Previous')),
                    ],
                    child: Text('Find'),
                  ),
                  ContextMenuItem(
                    trailing: Icon(LucideIcons.chevronRight),
                    items: [
                      ContextMenuItem(child: Text('Paid')),
                      ContextMenuItem(child: Text('Pending')),
                      ContextMenuItem(child: Text('Unpaid')),
                    ],
                    child: Text('Mark As'),
                  ),
                ],
                child: const Text('Edit'),
              ),
              MenubarItem(
                items: const [
                  ContextMenuItem(
                    trailing: Icon(LucideIcons.chevronRight),
                    items: [
                      ContextMenuItem(child: Text('Status')),
                      ContextMenuItem(child: Text('Customer')),
                      ContextMenuItem(child: Text('Month')),
                    ],
                    child: Text('Group By'),
                  ),
                  ContextMenuItem(
                    trailing: Icon(LucideIcons.chevronRight),
                    items: [
                      ContextMenuItem(child: Text('Date')),
                      ContextMenuItem(child: Text('Amount')),
                      ContextMenuItem(child: Text('Customer')),
                    ],
                    child: Text('Sort By'),
                  ),
                  ContextMenuItem(
                    trailing: Icon(LucideIcons.chevronRight),
                    items: [
                      ContextMenuItem(child: Text('Invoice')),
                      ContextMenuItem(child: Text('Status')),
                      ContextMenuItem(child: Text('Amount')),
                      ContextMenuItem(child: Text('Due Date')),
                    ],
                    child: Text('Columns'),
                  ),
                  ContextMenuItem(
                    trailing: Icon(LucideIcons.chevronRight),
                    items: [
                      ContextMenuItem(child: Text('Compact')),
                      ContextMenuItem(child: Text('Default')),
                      ContextMenuItem(child: Text('Comfortable')),
                    ],
                    child: Text('Density'),
                  ),
                  ContextMenuItem(
                    trailing: Icon(LucideIcons.chevronRight),
                    items: [
                      ContextMenuItem(child: Text('USD')),
                      ContextMenuItem(child: Text('EUR')),
                      ContextMenuItem(child: Text('SEK')),
                      ContextMenuItem(child: Text('GBP')),
                    ],
                    child: Text('Currency'),
                  ),
                  ContextMenuItem(
                    trailing: Icon(LucideIcons.chevronRight),
                    items: [
                      ContextMenuItem(child: Text('75%')),
                      ContextMenuItem(child: Text('100%')),
                      ContextMenuItem(child: Text('125%')),
                      ContextMenuItem(child: Text('150%')),
                    ],
                    child: Text('Zoom'),
                  ),
                ],
                child: const Text('View'),
              ),
            ],
          ),
          Tabs<String>(
            value: 'invoices',
            tabs: [
              Tab(
                value: 'invoices',
                // TableView is a 2-D scroll view with no shrink-wrap, so it
                // needs a bounded height inside a scrolling card.
                content: SizedBox(
                  height: 140,
                  child: FinesseTable.list(
                    // Without this the columns size to their content and the
                    // table stops short of the card's edge.
                    columnSpanExtent: (index) => index == 2
                        ? const RemainingTableSpanExtent()
                        : const FractionalTableSpanExtent(.3),
                    header: const [
                      FinesseTableCell.header(child: Text('Invoice')),
                      FinesseTableCell.header(child: Text('Status')),
                      FinesseTableCell.header(
                        alignment: Alignment.centerRight,
                        child: Text('Amount'),
                      ),
                    ],
                    children: [
                      for (final row in _rows)
                        [
                          FinesseTableCell(child: Text(row.$1)),
                          FinesseTableCell(
                            child: Badge.secondary(child: Text(row.$2)),
                          ),
                          FinesseTableCell(
                            alignment: Alignment.centerRight,
                            child: Text(row.$3),
                          ),
                        ],
                    ],
                  ),
                ),
                child: const Text('Invoices'),
              ),
              Tab(
                value: 'layout',
                content: SizedBox(
                  height: 120,
                  child: ResizablePanelGroup(
                    showHandle: true,
                    children: [
                      ResizablePanel(
                        id: 0,
                        defaultSize: .35,
                        child: Center(
                          child: Text('Sidebar', style: theme.textTheme.muted),
                        ),
                      ),
                      ResizablePanel(
                        id: 1,
                        defaultSize: .65,
                        child: Center(
                          child: Text('Content', style: theme.textTheme.muted),
                        ),
                      ),
                    ],
                  ),
                ),
                child: const Text('Layout'),
              ),
            ],
          ),
          FinesseRow(
            spacing: 2,
            children: [
              Toggle(
                value: bold,
                semanticLabel: 'Bold',
                onChanged: (v) => setState(() => bold = v),
                child: const Icon(LucideIcons.bold, size: 16),
              ),
              Toggle(
                value: italic,
                semanticLabel: 'Italic',
                onChanged: (v) => setState(() => italic = v),
                child: const Icon(LucideIcons.italic, size: 16),
              ),
              const Spacer(),
              Button.ghost(
                onPressed: () => showCommandDialog<String>(
                  context: context,
                  placeholder: const Text('Type a command or search…'),
                  groups: [
                    CommandGroup(
                      heading: 'Actions',
                      items: [
                        CommandItem(
                          label: 'New invoice',
                          value: 'new',
                          leading: const Icon(LucideIcons.plus),
                          onSelected: () {},
                        ),
                        CommandItem(
                          label: 'Export CSV',
                          value: 'export',
                          leading: const Icon(LucideIcons.download),
                          onSelected: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: const Kbd.group(['⌘', 'K']),
                child: const Text('Search'),
              ),
            ],
          ),
          Collapsible(
            controller: collapsible,
            trigger: (context, open, toggle) => FinesseRow(
              spacing: 2,
              children: [
                Expanded(
                  child: Text(
                    '3 archived invoices',
                    style: theme.textTheme.small,
                  ),
                ),
                IconButton.ghost(
                  icon: Icon(
                    open ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 16,
                  ),
                  onPressed: toggle,
                ),
              ],
            ),
            child: Text(
              'Archived invoices are excluded from the totals above.',
              style: theme.textTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// The resolved palette, so a base/accent/chart choice can be judged directly
/// rather than inferred from the components using it.
class _PaletteCard extends StatelessWidget {
  const _PaletteCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final swatches = <(String, Color, Color)>[
      ('Primary', scheme.primary, scheme.primaryForeground),
      ('Secondary', scheme.secondary, scheme.secondaryForeground),
      ('Accent', scheme.accent, scheme.accentForeground),
      ('Muted', scheme.muted, scheme.mutedForeground),
      ('Card', scheme.card, scheme.cardForeground),
      ('Destructive', scheme.destructive, scheme.destructiveForeground),
    ];

    return _PreviewCard(
      title: 'Palette',
      description: 'Base colour, accent and chart ramp',
      child: FinesseColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 3,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (name, background, foreground) in swatches)
                _Swatch(
                  name: name,
                  background: background,
                  foreground: foreground,
                ),
            ],
          ),
          const Divider.horizontal(
            margin: EdgeInsets.symmetric(vertical: 4),
          ),
          Text('Chart ramp', style: theme.textTheme.muted),
          Row(
            children: [
              for (var i = 0; i < 5; i++)
                Expanded(
                  child: Container(
                    height: 28,
                    margin: EdgeInsets.only(right: i == 4 ? 0 : 4),
                    decoration: BoxDecoration(
                      color: scheme.charts[i],
                      borderRadius: theme.radii.sm,
                    ),
                  ),
                ),
            ],
          ),
          const Divider.horizontal(
            margin: EdgeInsets.symmetric(vertical: 4),
          ),
          Row(
            children: [
              Expanded(
                child: Text('Border and ring', style: theme.textTheme.muted),
              ),
              Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: scheme.background,
                  border: Border.all(color: scheme.border),
                  borderRadius: theme.radii.sm,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: scheme.ring,
                  borderRadius: theme.radii.sm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.name,
    required this.background,
    required this.foreground,
  });

  final String name;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: theme.radii.md,
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Text(
        name,
        style: theme.textTheme.muted.copyWith(color: foreground),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// The type ramp, which is what makes a style's typography visible: `lyra` and
/// `mira` set the UI a size smaller, `sera` sets titles in uppercase.
class _TypographyCard extends StatelessWidget {
  const _TypographyCard();

  static const _styles = <(String label, String styleKey, String sample)>[
    ('h1', 'h1', 'Taxing Laughter'),
    ('h2', 'h2', 'The People of the Kingdom'),
    ('h3', 'h3', 'The Joke Tax'),
    ('h4', 'h4', 'People stopped telling jokes'),
    ('p', 'p', 'The king repealed the joke tax.'),
    ('quote', 'blockquote', '"Everyone enjoys a good joke."'),
    ('table', 'table', "King's Treasury"),
    ('list', 'list', '1st level of puns: 5 gold coins'),
    ('lead', 'lead', 'A modal dialog that interrupts the user.'),
    ('large', 'large', 'Are you absolutely sure?'),
    ('small', 'small', 'Email address'),
    ('muted', 'muted', 'Enter your email address.'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final styleName = theme.style.name;
    final capitalizedStyle =
        '${styleName[0].toUpperCase()}${styleName.substring(1)}';

    TextStyle styleFor(String key) => switch (key) {
      'h1' => text.h1,
      'h2' => text.h2,
      'h3' => text.h3,
      'h4' => text.h4,
      'p' => text.p,
      'blockquote' => text.blockquote,
      'table' => text.table,
      'list' => text.list,
      'lead' => text.lead,
      'large' => text.large,
      'small' => text.small,
      'muted' => text.muted,
      _ => text.p,
    };

    final labelStyle = text.muted.copyWith(
      fontSize: 11,
      color: theme.colorScheme.mutedForeground,
    );

    Widget row(String label, TextStyle style, String sample) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: labelStyle),
          ),
          Expanded(
            child: Text(
              sample,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return _PreviewCard(
      title: 'Typography',
      trailing: Badge(child: Text(capitalizedStyle)),
      child: FinesseColumn(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          for (final (label, styleKey, sample) in _styles)
            row(label, styleFor(styleKey), sample),
        ],
      ),
    );
  }
}
