# Apple App Store Review Guidelines — Summary & Reference

> **Source:** [Apple Developer — App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
> **Last Updated by Apple:** February 6, 2026
> **Note:** This document is a structured summary for reference purposes. Always consult the [official guidelines](https://developer.apple.com/app-store/review/guidelines/) for the authoritative and complete text.

---

## Table of Contents

- [Introduction](#introduction)
- [Before You Submit](#before-you-submit)
- [1. Safety](#1-safety)
  - [1.1 Objectionable Content](#11-objectionable-content)
  - [1.2 User-Generated Content](#12-user-generated-content)
  - [1.3 Kids Category](#13-kids-category)
  - [1.4 Physical Harm](#14-physical-harm)
  - [1.5 Developer Information](#15-developer-information)
  - [1.6 Data Security](#16-data-security)
  - [1.7 Reporting Criminal Activity](#17-reporting-criminal-activity)
- [2. Performance](#2-performance)
  - [2.1 App Completeness](#21-app-completeness)
  - [2.2 Beta Testing](#22-beta-testing)
  - [2.3 Accurate Metadata](#23-accurate-metadata)
  - [2.4 Hardware Compatibility](#24-hardware-compatibility)
  - [2.5 Software Requirements](#25-software-requirements)
- [3. Business](#3-business)
  - [3.1 Payments](#31-payments)
  - [3.2 Other Business Model Issues](#32-other-business-model-issues)
- [4. Design](#4-design)
  - [4.1 Copycats](#41-copycats)
  - [4.2 Minimum Functionality](#42-minimum-functionality)
  - [4.3 Spam](#43-spam)
  - [4.4 Extensions](#44-extensions)
  - [4.5 Apple Sites and Services](#45-apple-sites-and-services)
  - [4.7 Mini Apps, Mini Games, Streaming Games, Chatbots, Plug-ins, and Game Emulators](#47-mini-apps-mini-games-streaming-games-chatbots-plug-ins-and-game-emulators)
  - [4.8 Login Services](#48-login-services)
  - [4.9 Apple Pay](#49-apple-pay)
  - [4.10 Monetizing Built-In Capabilities](#410-monetizing-built-in-capabilities)
- [5. Legal](#5-legal)
  - [5.1 Privacy](#51-privacy)
  - [5.2 Intellectual Property](#52-intellectual-property)
  - [5.3 Gaming, Gambling, and Lotteries](#53-gaming-gambling-and-lotteries)
  - [5.4 VPN Apps](#54-vpn-apps)
  - [5.5 Mobile Device Management](#55-mobile-device-management)
  - [5.6 Developer Code of Conduct](#56-developer-code-of-conduct)
- [After You Submit](#after-you-submit)

---

## Introduction

The App Store's guiding principle is to provide a safe experience for users and a great opportunity for developers. Every app is reviewed by experts, scanned for malware, and evaluated for safety, security, and privacy. In the EU, developers may also distribute notarized iOS/iPadOS apps via alternative app marketplaces or directly from their websites; in Japan, developers may distribute iOS apps from alternative marketplaces.

The guidelines are organized into five sections: Safety, Performance, Business, Design, and Legal. Apple emphasizes that the App Store is always evolving, and apps should evolve with it. Key introductory points include:

- Parental controls help protect children, but developers share that responsibility.
- Apps meant only for friends/family are better distributed via Xcode or Ad Hoc distribution.
- All viewpoints are welcome as long as apps are respectful and high quality.
- Attempting to cheat the system (tricking review, stealing data, copying other developers, manipulating ratings) will result in app removal and expulsion from the Apple Developer Program.
- Developers are responsible for all content in their apps, including third-party SDKs, ad networks, and analytics services.

---

## Before You Submit

Apple provides a pre-submission checklist to help developers avoid common pitfalls that slow down reviews or cause rejections. Apps that no longer function or are no longer actively supported may be removed from the App Store.

The checklist includes: testing for crashes and bugs, ensuring all metadata is complete and accurate, updating contact information, providing App Review with full access (including demo accounts or demo modes), enabling backend services during review, including detailed explanations of non-obvious features in review notes, and checking your app against Apple's various documentation and design guidelines.

---

## 1. Safety

Apps on the App Store must feel safe — free from offensive content, device damage risks, and physical harm. Some safety rules also apply to Notarization for iOS and iPadOS apps.

### 1.1 Objectionable Content

Apps must not include offensive, insensitive, upsetting, or tasteless content. Specific sub-rules cover:

- **1.1.1** — Defamatory, discriminatory, or mean-spirited content targeting religion, race, sexual orientation, gender, or other groups is prohibited. Political satirists and humorists are generally exempt.
- **1.1.2** — Realistic depictions of people or animals being killed, maimed, or tortured are not allowed. Game enemies cannot solely target a specific real-world group.
- **1.1.3** — Content encouraging illegal/reckless use of weapons or facilitating firearm/ammunition purchases is prohibited.
- **1.1.4** — Overtly sexual or pornographic material is not permitted, including hookup apps facilitating prostitution, human trafficking, or exploitation.
- **1.1.5** — Inflammatory religious commentary or misleading quotations of religious texts are banned.
- **1.1.6** — False information and features (fake location trackers, trick functionality) are not allowed. "For entertainment purposes" disclaimers do not override this. Anonymous/prank call or messaging apps will be rejected.
- **1.1.7** — Harmful concepts capitalizing on recent events such as violent conflicts, terrorist attacks, and epidemics are prohibited.

### 1.2 User-Generated Content

Apps with user-generated content (UGC) or social networking features must include: a method for filtering objectionable material, a mechanism for reporting offensive content with timely responses, the ability to block abusive users, and published contact information.

Apps primarily used for pornographic content, anonymous chat, objectification of real people, physical threats, or bullying may be removed without notice. Apps may display incidental mature content from web-based services if it is hidden by default and user-activated via the developer's website.

**1.2.1 Creator Content** — Apps featuring content from a community of "creators" are supported if properly moderated. Such content (video, articles, audio, casual games) is treated as UGC and must follow Guidelines 1.2 and 3.1.1. Creator apps must provide age-identification mechanisms and restrict underage access to content exceeding the app's age rating.

### 1.3 Kids Category

The Kids Category is designed for apps specifically built for younger users. These apps must not include links out of the app, purchasing opportunities, or distractions unless behind a parental gate. Once an app enters the Kids Category, it must continue to meet these requirements in future updates.

Kids Category apps must comply with applicable children's privacy laws, must not send personally identifiable information or device information to third parties, and should not include third-party analytics or advertising. Limited exceptions exist for analytics services that don't collect identifiable child data, and for contextual advertising with documented practices for age-appropriate content.

### 1.4 Physical Harm

Apps that risk physical harm may be rejected:

- **1.4.1** — Medical apps providing inaccurate data face greater scrutiny. Apps claiming to measure health metrics using only device sensors (x-rays, blood pressure, etc.) are not permitted. Apps should remind users to consult a doctor.
- **1.4.2** — Drug dosage calculators must come from approved entities (drug manufacturers, hospitals, universities, etc.) or receive FDA/equivalent approval.
- **1.4.3** — Apps encouraging consumption of tobacco, vape products, illegal drugs, or excessive alcohol are not permitted. Sale of controlled substances is not allowed (except licensed pharmacies and legal cannabis dispensaries).
- **1.4.4** — DUI checkpoint apps may only display data published by law enforcement; they must never encourage drunk driving or reckless behavior.
- **1.4.5** — Apps should not urge users to participate in activities or use devices in ways risking physical harm.

### 1.5 Developer Information

Apps and their Support URLs must include an easy way to contact the developer. Wallet passes must include valid contact info from the issuer and be signed with a dedicated certificate.

### 1.6 Data Security

Apps must implement appropriate security measures for handling user information and preventing unauthorized access, disclosure, or use by third parties. (See also Guideline 5.1.)

### 1.7 Reporting Criminal Activity

Apps for reporting alleged criminal activity must involve local law enforcement and can only be offered in countries/regions where such involvement is active.

---

## 2. Performance

### 2.1 App Completeness

**(a)** Submissions must be final versions with all metadata and functional URLs. Placeholder text and temporary content must be removed. Apps must be tested on-device, and demo accounts or built-in demo modes must be provided if login is required.

**(b)** In-app purchases must be complete, up-to-date, visible to reviewers, and functional.

### 2.2 Beta Testing

Demos, betas, and trials do not belong on the App Store — use TestFlight instead. TestFlight apps must comply with App Review Guidelines and cannot be distributed in exchange for compensation.

### 2.3 Accurate Metadata

All app metadata (descriptions, screenshots, previews, privacy information) must accurately reflect the app's core experience and be kept up-to-date.

- **2.3.1** — No hidden, dormant, or undocumented features. All new features must be described in App Store Connect notes. Misleading marketing is grounds for removal.
- **2.3.2** — Apps with in-app purchases must clearly indicate which items require additional purchases.
- **2.3.3** — Screenshots must show the app in use, not just title art, login pages, or splash screens.
- **2.3.4** — Previews may only use video screen captures of the app itself, with optional narration and overlays.
- **2.3.5** — Select the most appropriate category; Apple may change it if it's clearly wrong.
- **2.3.6** — Age rating questions must be answered honestly to align with parental controls.
- **2.3.7** — App names must be unique and limited to 30 characters. Metadata must not be stuffed with trademarked terms, popular app names, or irrelevant phrases.
- **2.3.8** — All metadata must be appropriate for a 4+ age rating, regardless of the app's actual rating. "For Kids" and "For Children" are reserved for the Kids Category.
- **2.3.9** — Developers must secure rights to all materials in icons, screenshots, and previews, and use fictional account data.
- **2.3.10** — Apps should focus on the Apple platform experience; don't reference other mobile platforms or alternative marketplaces in metadata.
- **2.3.11** — Pre-order apps must be complete as submitted; material changes require restarting pre-order sales.
- **2.3.12** — "What's New" text must clearly describe new features and significant changes.
- **2.3.13** — In-app events must be timely, accurately described, and properly linked. Events may be monetized per Section 3 rules.

### 2.4 Hardware Compatibility

- **2.4.1** — iPhone apps should run on iPad whenever possible.
- **2.4.2** — Apps must use power efficiently and not drain battery, generate excessive heat, or strain device resources. No cryptocurrency mining or unrelated background processes.
- **2.4.3** — Apple TV apps must work with the Siri remote or third-party game controllers. Required peripherals must be stated in metadata.
- **2.4.4** — Apps should never suggest restarting the device or modifying unrelated system settings.
- **2.4.5** — Mac App Store apps have additional requirements covering sandboxing, packaging via Xcode, no auto-launch behavior, no standalone app downloads, no root privilege escalation, no custom licensing, Mac App Store-only updates, current OS compatibility, and self-contained localization.

### 2.5 Software Requirements

- **2.5.1** — Apps may only use public APIs, run on the current OS, and phase out deprecated features. Frameworks must be used for their intended purposes.
- **2.5.2** — Apps must be self-contained and may not download/execute code that changes features, with limited exceptions for educational apps.
- **2.5.3** — Apps transmitting viruses or harmful code will be rejected.
- **2.5.4** — Background services may only be used for intended purposes (VoIP, audio, location, etc.).
- **2.5.5** — Apps must be fully functional on IPv6-only networks.
- **2.5.6** — Web-browsing apps must use WebKit. Developers may apply for entitlements to use alternative browser engines.
- **2.5.8** — Apps creating alternate desktop/home screen environments will be rejected.
- **2.5.9** — Apps must not alter standard switches or native UI elements/behaviors.
- **2.5.11** — SiriKit/Shortcuts integrations must only register for intents the app can handle. Vocabulary must relate to the app. Siri requests should be resolved directly without inserting ads.
- **2.5.12** — CallKit/SMS Fraud Extension apps must only block confirmed spam and clearly describe their criteria.
- **2.5.13** — Facial recognition for auth must use LocalAuthentication where possible, with an alternate method for users under 13.
- **2.5.14** — Apps must request explicit consent and provide clear visual/audible indication when recording user activity.
- **2.5.15** — File picker apps must include items from the Files app and iCloud documents.
- **2.5.16** — Widgets, extensions, and notifications must relate to the app's content. App Clips must be included in the main binary and cannot contain ads.
- **2.5.17** — Apps supporting Matter must use Apple's Matter support framework for pairing. Non-Apple Matter components must be CSA-certified.
- **2.5.18** — Display advertising must be limited to the main app binary. Ads must be age-appropriate, transparent about targeting data, and must not use behavioral targeting based on sensitive data. Interstitial ads must have clearly visible close/skip buttons.

---

## 3. Business

Apps' business models must be clear. Pricing is up to developers, but Apple will reject apps that are clear rip-offs or attempt to manipulate reviews/chart rankings.

### 3.1 Payments

**3.1.1 In-App Purchase (IAP):** Unlocking features or functionality within an app requires in-app purchase. Apps may not use their own mechanisms (license keys, QR codes, crypto, etc.). Key rules include:

- Credits/currencies purchased via IAP may not expire; restorable purchases must have a restore mechanism.
- Gifting of IAP-eligible items is allowed (refunds only to original purchaser).
- Loot boxes must disclose odds of receiving each item type.
- Digital gift cards redeemable for digital goods must use IAP; physical gift cards may use other payment methods.
- Non-subscription apps may offer free time-based trials via a Non-Consumable IAP at Price Tier 0.
- Apps may sell NFT-related services via IAP. Users may view their own NFTs (without unlocking app features) and browse others' NFT collections.

**3.1.1(a) Link to Other Purchase Methods:** Developers may apply for entitlements (StoreKit External Purchase Link, Music Streaming Services) to link to their website for alternative purchase options in specific regions. US storefront apps may include external purchase links without these entitlements. Misleading marketing related to entitlements will result in removal.

**3.1.2 Subscriptions:** Auto-renewable subscriptions must provide ongoing value and last at least seven days. Key sub-rules:

- **(a) Permissible uses** — Subscriptions are appropriate for new content, multiplayer support, substantial updates, media libraries, SaaS, cloud support, etc. Subscriptions must work across all user devices. Existing paid functionality must not be taken away when transitioning to subscription models. Scam subscription practices result in removal.
- **(b) Upgrades/Downgrades** — Users must have a seamless upgrade/downgrade experience without accidental duplicate subscriptions.
- **(c) Subscription Information** — Clear descriptions of what the user gets must be provided before purchase.

**3.1.3 Other Purchase Methods:** Certain app categories may use non-IAP payment methods:

- **(a) Reader Apps** — May allow access to previously purchased content (magazines, newspapers, books, audio, music, video). May offer free-tier account creation. Developers may apply for the External Link Account Entitlement.
- **(b) Multiplatform Services** — May allow access to content/subscriptions acquired on other platforms, provided those items are also available as IAP.
- **(c) Enterprise Services** — Apps sold directly to organizations for employees/students may allow access to previously-purchased content.
- **(d) Person-to-Person Services** — Real-time one-on-one services (tutoring, medical consultations, etc.) may use non-IAP payments. One-to-few/many services must use IAP.
- **(e) Goods and Services Outside the App** — Physical goods or services consumed outside the app must use non-IAP payments (Apple Pay, credit card, etc.).
- **(f) Free Stand-alone Apps** — Free companions to paid web-based tools (VoIP, cloud storage, etc.) don't need IAP if there's no purchasing in the app.
- **(g) Advertising Management Apps** — Apps solely for managing ad campaigns across media don't need IAP for campaign purchases.

**3.1.4 Hardware-Specific Content:** In limited cases, features dependent on specific hardware may be unlocked without IAP. Optional toy/product integration may unlock functionality if an IAP option is also available.

**3.1.5 Cryptocurrencies:** Wallets must be offered by organizations. Mining must be off-device. Exchanges must be properly licensed. ICOs and crypto-securities trading must come from established financial institutions. Crypto rewards for tasks (downloading apps, social posting) are not permitted.

### 3.2 Other Business Model Issues

**3.2.1 Acceptable:** Displaying your own apps for purchase, recommending curated third-party app collections, disabling expired rental content, Wallet passes for payments/offers/ID, free insurance apps, approved nonprofit fundraising with Apple Pay, individual monetary gifts (100% to receiver), and financial trading apps from licensed institutions.

**3.2.2 Unacceptable:** Creating App Store-like interfaces, artificially inflating ad impressions, collecting charity funds within the app (unless approved nonprofit), arbitrarily restricting app access, manipulating user visibility on other services, binary options trading apps, personal loan apps with APR above 36% or terms under 60 days, and forcing users to rate/review/download as a condition of use.

---

## 4. Design

Apple customers value simplicity, refinement, and innovation. The following are minimum design standards for App Store approval.

### 4.1 Copycats

**(a)** Don't copy popular apps or make minor changes to another app and pass it off as your own.
**(b)** Impersonating other apps or services violates the Developer Code of Conduct.
**(c)** You cannot use another developer's icon, brand, or product name without approval.

### 4.2 Minimum Functionality

Apps must include features, content, and UI that go beyond a repackaged website. Apps that are simply a song, movie, book, or game guide should be submitted to the appropriate Apple store (iTunes, Apple Books).

- **4.2.1** — ARKit apps must provide rich, integrated AR experiences.
- **4.2.2** — Apps shouldn't primarily be marketing materials, advertisements, or link collections.
- **4.2.3** — Apps should work standalone without requiring another app. Additional resource downloads must be disclosed.
- **4.2.6** — Apps from commercialized templates will be rejected unless submitted by the content provider directly. Template providers may create aggregated/picker-model apps.
- **4.2.7** — Remote desktop clients must connect only to user-owned personal computers or game consoles on a local/LAN network. The client UI must not resemble iOS or App Store interfaces.

### 4.3 Spam

**(a)** Don't create multiple Bundle IDs for the same app. Use in-app purchase for variations.
**(b)** Avoid saturated categories unless providing a unique, high-quality experience. Spamming the store may result in developer program removal.

### 4.4 Extensions

Apps hosting extensions must comply with Apple's Extension Programming Guides and include functionality (help screens, settings, etc.).

- **4.4.1** — Keyboard extensions must provide keyboard input, follow Sticker guidelines if applicable, support progression to the next keyboard, work without full network access, and only collect activity to enhance keyboard functionality. They must not launch other apps or repurpose button behaviors.
- **4.4.2** — Safari extensions must run on the current Safari version, must not interfere with system/Safari UI, and should not claim access to more websites than necessary.

### 4.5 Apple Sites and Services

- **4.5.1** — Apps may use approved Apple RSS feeds but must not scrape Apple sites or create rankings from Apple data.
- **4.5.2** — Apple Music (MusicKit) usage requires user-initiated playback, standard media controls, and no monetization of Apple Music access. Music files must not be downloaded/shared except as explicitly permitted. Cover art may only be used in connection with music playback.
- **4.5.3** — Apple Services (Game Center, Push Notifications) must not be used for spam, phishing, or unsolicited messages.
- **4.5.4** — Push Notifications must not be required for app functionality. Promotional notifications require explicit opt-in and an opt-out mechanism.
- **4.5.5** — Game Center Player IDs must be used per Game Center terms and not displayed publicly.
- **4.5.6** — Apps may use Unicode-rendered Apple emoji but may not use them on other platforms or embed them in binaries.

### 4.7 Mini Apps, Mini Games, Streaming Games, Chatbots, Plug-ins, and Game Emulators

Apps may offer HTML5/JavaScript mini apps and games, streaming games, chatbots, plug-ins, and retro game console/PC emulator downloads. Developers are responsible for all such software complying with the Guidelines and applicable laws.

- **4.7.1** — Must follow privacy guidelines, include content moderation mechanisms, and follow Guideline 3.1 for digital goods/services.
- **4.7.2** — Must not extend or expose native platform APIs without Apple's permission.
- **4.7.3** — Must not share data or privacy permissions without explicit per-instance user consent.
- **4.7.4** — Must provide an index of available software with universal links.
- **4.7.5** — Must identify content exceeding the app's age rating and use age restriction mechanisms.

### 4.8 Login Services

Apps using third-party/social login for the primary account must also offer an equivalent alternative login that limits data collection to name and email, allows private email, and doesn't collect interactions for advertising.

Exceptions include: apps exclusively using the company's own login system, alternative app marketplace apps, education/enterprise apps requiring existing institutional accounts, apps using government/industry-backed citizen ID systems, and clients for specific third-party services.

### 4.9 Apple Pay

Apps using Apple Pay must provide all material purchase information before sale and follow Apple Pay branding guidelines. Apps with recurring Apple Pay payments must disclose renewal term length, what's provided each period, actual charges, and cancellation instructions.

### 4.10 Monetizing Built-In Capabilities

You may not monetize hardware/OS built-in capabilities (Push Notifications, camera, gyroscope) or Apple services/technologies (Apple Music access, iCloud storage, Screen Time APIs).

---

## 5. Legal

Apps must comply with all applicable legal requirements in every location where they're available. Apps soliciting, promoting, or encouraging criminal or reckless behavior will be rejected.

### 5.1 Privacy

User privacy protection is paramount in the Apple ecosystem.

**5.1.1 Data Collection and Storage:**

- **(i) Privacy Policies** — All apps must link to a privacy policy in App Store Connect and within the app. The policy must identify what data is collected and how, confirm third-party data sharing provides equal privacy protection, and explain data retention/deletion policies and consent revocation.
- **(ii) Permission** — User consent is required for all data collection. Paid functionality must not depend on data access consent. Clear purpose strings are required.
- **(iii) Data Minimization** — Only request data relevant to core functionality. Use out-of-process pickers or share sheets when possible.
- **(iv) Access** — Respect permission settings. Don't manipulate or force consent. Provide alternatives for users who decline.
- **(v) Account Sign-In** — Allow use without login when possible. Apps supporting account creation must also offer account deletion. Social network integration rules apply.
- **(vi)** — Surreptitious password/data discovery results in developer program removal.
- **(vii)** — SafariViewController must visibly present information and not be used for hidden tracking.
- **(viii)** — Apps compiling personal data from sources other than the user (including public databases) without explicit consent are not permitted.
- **(ix)** — Apps in highly regulated fields must be submitted by a legal entity providing the services.
- **(x)** — Basic contact info requests must be optional and not condition features on providing it.

**5.1.2 Data Use and Sharing:**

- **(i)** — Personal data requires permission before use, transmission, or sharing. Data shared with third-party AI requires explicit disclosure and permission. App Tracking Transparency APIs are required for tracking. Apps must not require enabling system functionalities for access or compensation.
- **(ii)** — Data collected for one purpose cannot be repurposed without further consent.
- **(iii)** — Apps must not build user profiles from collected data or attempt to identify anonymous users.
- **(iv)** — Contact/Photo data must not be used to build databases for sale/distribution or to track installed apps.
- **(v)** — Contact data must not be used for unsolicited outreach. No "Select All" contact options.
- **(vi)** — Data from HomeKit, HealthKit, Clinical Health Records, MovementDisorder, ClassKit, ARKit, Camera/Photo APIs must not be used for marketing, advertising, or data mining.
- **(vii)** — Apple Pay data may only be shared to facilitate/improve goods and services delivery.

**5.1.3 Health and Health Research:**

- **(i)** — Health/fitness/medical research data cannot be used for advertising or marketing — only health management/research with permission.
- **(ii)** — Apps must not write false data into HealthKit or store personal health info in iCloud.
- **(iii)** — Human subject research requires participant consent covering nature, risks, confidentiality, contact info, and withdrawal process.
- **(iv)** — Health research apps need independent ethics review board approval.

**5.1.4 Kids:**

- **(a)** — Special care is required with children's personal data. Apps must comply with COPPA, GDPR, and similar laws. Apps primarily for kids should not include third-party analytics or advertising.
- **(b)** — Limited exceptions for analytics/advertising exist if services adhere to Guideline 1.3 terms. Apps collecting children's personal info must include a privacy policy and comply with children's privacy statutes.

**5.1.5 Location Services:** Location data use must be directly relevant to app features. Location-based APIs should not be used for emergency services or autonomous vehicle control (with small device exceptions). User notification and consent are required.

### 5.2 Intellectual Property

Apps must only include content the developer created or has licensed. Key rules:

- **5.2.1** — Don't use protected third-party trademarks, copyrights, or patents without permission.
- **5.2.2** — Third-party service usage must be permitted by the service's terms of use.
- **5.2.3** — Apps should not facilitate illegal file sharing or unauthorized downloading from third-party sources.
- **5.2.4** — Don't suggest Apple endorses or is the source of your app.
- **5.2.5** — Don't create apps confusingly similar to Apple products, interfaces, or apps. Apps may not include Apple emoji. Various rules govern use of iTunes/Apple Music previews, Activity rings, and Apple Weather data.

### 5.3 Gaming, Gambling, and Lotteries

This is one of the most regulated areas on the App Store:

- **5.3.1** — Sweepstakes/contests must be developer-sponsored.
- **5.3.2** — Official rules must state Apple is not a sponsor.
- **5.3.3** — IAP cannot purchase credit/currency for real money gaming.
- **5.3.4** — Real money gaming apps must have proper licensing, be geo-restricted, and be free. Illegal gambling aids (card counters) are not permitted.

### 5.4 VPN Apps

VPN apps must use NEVPNManager API and be offered by developers enrolled as organizations. They must clearly declare data collection practices, must not sell/share user data with third parties, must not violate local laws, and must provide license information where required. Non-compliant apps will be removed and developers may be expelled from the program.

### 5.5 Mobile Device Management

MDM apps require Apple-granted capability and may only be offered by commercial enterprises, educational institutions, government agencies, or (in limited cases) parental control/device security companies. They must declare data collection, comply with applicable laws, and not sell/share user data. Configuration profile apps must also adhere to these requirements.

### 5.6 Developer Code of Conduct

Developers must treat everyone with respect across all interactions (App Store reviews, customer support, communications with Apple). Harassment, discrimination, intimidation, and bullying are prohibited.

- **5.6.1 App Store Reviews** — Respond respectfully to customer reviews. Use the provided API for review prompts; custom review prompts are disallowed.
- **5.6.2 Developer Identity** — All representations must be accurate, truthful, relevant, and up-to-date.
- **5.6.3 Discovery Fraud** — Manipulating charts, search, reviews, or referrals is not permitted.
- **5.6.4 App Quality** — Excessive negative reviews or refund requests may indicate a developer is not meeting quality expectations and may factor into Developer Code of Conduct compliance.

---

## After You Submit

Key information about the post-submission process:

- **Timing** — App Review examines apps as soon as possible; complex apps or repeated violations take longer.
- **Status Updates** — Current app status is reflected in App Store Connect.
- **Expedite Requests** — Available for critical timing issues; abuse of the system may lead to future request rejections.
- **Release Date** — Future-dated apps won't appear until the set date, even after approval. Allow up to 24 hours for global storefront appearance.
- **Rejections** — Use App Store Connect to communicate with App Review, provide additional info, and help improve the process.
- **Appeals** — Developers may submit an appeal if they disagree with a review outcome and may also suggest guideline changes.
- **Bug Fix Submissions** — For apps already on the App Store, bug fixes won't be delayed over guideline violations except for legal or safety issues.

---

*This document is a structured summary of Apple's App Store Review Guidelines for quick reference. For the official, authoritative text, always visit the [Apple Developer Guidelines page](https://developer.apple.com/app-store/review/guidelines/).*
