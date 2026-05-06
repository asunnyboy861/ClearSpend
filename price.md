# Pricing Configuration

## Monetization Model: Subscription (IAP)

## Subscription Group
- **Group Name**: ClearSpend Premium
- **Group ID**: ClearSpend_Premium

## Subscription Tiers

### 1. Monthly Subscription
- **Reference Name**: Monthly Premium
- **Product ID**: `com.zzoutuo.ClearSpend.monthly`
- **Price**: $3.99 per month
- **Display Name**: ClearSpend Premium Monthly
- **Description**: Full access to all premium features
- **Localization**: English (US)

### 2. Yearly Subscription
- **Reference Name**: Yearly Premium
- **Product ID**: `com.zzoutuo.ClearSpend.yearly`
- **Price**: $19.99 per year (58% savings vs monthly)
- **Display Name**: ClearSpend Premium Yearly
- **Description**: Best value - save 58% annually
- **Localization**: English (US)

### 3. Lifetime Purchase
- **Reference Name**: Lifetime Access
- **Product ID**: `com.zzoutuo.ClearSpend.lifetime`
- **Price**: $49.99 one-time
- **Display Name**: ClearSpend Lifetime
- **Description**: Pay once, use forever
- **Localization**: English (US)

## Free Tier Features
- Track up to 50 transactions per month
- Basic expense splitting (equal split only)
- Dashboard with real spending overview
- Up to 2 groups
- Manual transaction entry

## Premium Features (Subscription Required)
- Unlimited transactions
- Receipt OCR scanning with line-item splitting
- Custom split ratios (percentage, shares, exact amounts)
- Unlimited groups
- Smart payment reminders
- Debt simplification algorithm
- Venmo deep link integration
- Advanced statistics and charts
- Budget management with alerts
- CSV/JSON data export
- iCloud sync across devices

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to paid monthly)

## Policy Pages Required
- Support Page: ✅ (Must include subscription management info)
- Privacy Policy: ✅
- Terms of Use: ✅ (REQUIRED for subscription apps)

## Apple IAP Compliance Checklist
- [ ] Auto-renewal terms included in Terms
- [ ] Cancellation instructions included
- [ ] Pricing clearly stated
- [ ] Free trial terms included
- [ ] Restore purchases functionality implemented
