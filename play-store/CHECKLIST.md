# NeighborHub — Play Store publish checklist

## Done in this project
- [x] App display name set to NeighborHub
- [x] Application ID / package: com.neighborhub1.app
- [x] In-app Privacy Policy screen (More → Privacy Policy)
- [x] Privacy policy webpage copy (PRIVACY_POLICY.md)
- [x] Play listing copy (LISTING.txt)
- [x] High-res icon: icons/icon-512.png
- [x] Feature graphic: graphics/feature-graphic-1024x500.png
- [x] Phone screenshots: screenshots/
- [x] Signed release AAB: play-store/aab/app-release.aab
- [x] Maps API key moved to android/local.properties (restrict this key in Google Cloud)

## You must still do in Play Console / Google Cloud
- [ ] Create / verify your Google Play developer account
- [ ] Host PRIVACY_POLICY.md as a public HTTPS page and add the URL in Play Console
- [ ] Paste the same URL into AppStrings.privacyPolicyUrl
- [ ] Restrict the Maps API key to package com.neighborhub1.app + your upload/app-signing SHA-1
- [ ] Upload AAB from build/app/outputs/bundle/release/app-release.aab
- [ ] Upload icon-512.png, feature-graphic-1024x500.png, and screenshots
- [ ] Paste LISTING.txt short + full description
- [ ] Complete Content ratings, Data safety (Location = optional, app functionality), Target audience
- [ ] Back up android/upload-keystore.jks and android/key.properties offline — losing them means you cannot update the app
