# AI Report and Delivery Backlog — 10 November 2026

## Purpose

This document records how Codex AI was used during the first delivery of **Donaciones Mexico Dreamin**, the work completed in the repository and Salesforce org, and the work that remains dependent on manual organization configuration. It is a delivery record, not a claim that pending external configuration has already been completed.

## How AI was used

Codex AI was used as a development collaborator under student direction. Its work included:

- Reading the assigned requirements and turning them into a technically scoped implementation plan for Delivery 1.
- Creating and organizing the Salesforce DX source under `salesforce/`.
- Designing the custom objects, fields, validation rules, Apex classes, Lightning Web Components, tests, permissions, and Experience Cloud-facing UI.
- Diagnosing deployment errors iteratively from Salesforce CLI output and correcting metadata issues without adding credentials to the repository.
- Deploying the source to the authorized practice org (`jDiaz`), querying the org to validate records, and creating the sample campaign **Becas STEM Yucatán** with a MXN 10,000 goal.
- Improving the public campaign catalog visual design and preparing the Experience Cloud component for use in the site builder.
- Configuring the least-privilege guest-access source metadata: campaign read access, Apex class access, and a sharing rule limited to active campaigns.
- Investigating the current anonymous-site error using a temporary Salesforce debug trace. The evidence shows the request reaches the public runtime but is rejected before `getActiveCampaigns` runs; the remaining required manual site preference is documented below.
- Maintaining Git history and pushing only the feature branch. No production secrets, Stripe keys, or direct donation-record permissions were added to Git.

The student retained control over Salesforce Experience Cloud publication, Guest User site preferences, Stripe credentials, and any final merge or public repository decisions.

## Evidence-based implementation backlog

| ID | AI task | Status | Evidence / result |
| --- | --- | --- | --- |
| AI-01 | Reorganize the Salesforce DX project under `salesforce/` | Done | DX source, config, manifest, and `sfdx-project.json` reside in `salesforce/`. |
| AI-02 | Implement `Campaign__c` and `Donation__c` data model | Done | Custom-object metadata and related fields/validation rules are in the Salesforce source. |
| AI-03 | Add campaign progress logic based only on paid donations | Done | `PublicCampaignController` calculates raised totals from paid donation records. |
| AI-04 | Build public campaign catalog LWC | Done | `campaignCatalog` displays active campaigns, goal, progress, and donation entry point. |
| AI-05 | Build donation and thank-you Experience Cloud components | Done | Donation, thank-you, and donor-wall components were added to the source; Stripe configuration remains external. |
| AI-06 | Add controlled Apex services and automated tests | Done | Public controller classes and test classes were created and deployed successfully. |
| AI-07 | Apply validation rules for positive amounts/goals, RFC rules, invoice/anonymous incompatibility | Done | Validation-rule metadata is included in the DX project. |
| AI-08 | Create minimum Guest User permission set | Done | `Donation_Public_Guest` gives `Campaign__c` read access and required Apex class access; it does not grant direct `Donation__c` access. |
| AI-09 | Assign the Guest permission set in `jDiaz` | Done | Assignment was verified for the Donaciones Mexico Dreamin Guest User. |
| AI-10 | Create active-campaign sharing rule for Guest User | Done | `Campaign__c.Active_Campaigns_for_Guests` deployed successfully. It shares only `Is_Active__c = true` records as Read Only. Commit `e749372`. |
| AI-11 | Create the initial campaign record | Done | **Becas STEM Yucatán**, active, goal MXN 10,000, was verified in `jDiaz`. |
| AI-12 | Improve public catalog styling | Done | Updated LWC styles and Experience Builder preview show the redesigned donation landing section. |
| AI-13 | Verify Salesforce deployment | Done | The guest sharing-rule deployment succeeded with deployment ID `0Afaj00000r9rRZCAY`. |
| AI-14 | Keep repository free of secrets | Done | Stripe credentials were not committed; `git status` was clean after the guest-sharing commit. |
| AI-15 | Diagnose anonymous campaign API error | Done (diagnosis) | Browser reports HTTP 400 at `/webruntime/api/apex/execute`; temporary guest trace confirms the public controller is loaded but method execution is not reached. |

## Pending backlog requiring manual configuration or external credentials

| ID | Task | Owner | Why it remains pending |
| --- | --- | --- | --- |
| P-01 | Enable **Allow guest users to access public APIs** in Experience Workspaces → Administration → Preferences, then publish | Student / Salesforce site administrator | This is an Experience Cloud site setting that must be enabled in the org UI. Until enabled, the public runtime rejects the Apex request with HTTP 400. |
| P-02 | Verify anonymously that **Becas STEM Yucatán** appears, then temporarily deactivate/reactivate it to verify the sharing-rule filter | Student | Requires browser/Experience Cloud verification after P-01. |
| P-03 | Configure Stripe Test secret and permitted return URLs in Salesforce Named Credential `Stripe_Test` | Student / Stripe account owner | API secrets must be created and stored in the org, never in Git or AI chat. |
| P-04 | Perform a Stripe Test Checkout and validate the safe thank-you return flow | Student | Depends on P-03. |
| P-05 | Configure email delivery and manually test staff confirmation/comprobante | Student / org administrator | Depends on org email configuration. |
| P-06 | Capture final anonymous-site and Stripe evidence screenshots | Student | Depends on P-01 through P-04. |
| P-07 | Review PR #19 and merge only after manual acceptance tests pass | Student | Merge responsibility remains with the repository owner. |

## Security decisions

- `Donation__c` is not made readable, editable, or shareable to anonymous visitors.
- The Guest User has read-only access limited to active `Campaign__c` records.
- The guest sharing rule uses `Is_Active__c = true`; inactive campaigns remain excluded.
- Stripe secrets are intentionally absent from source control.
- The public UI does not expose arbitrary donation-record IDs for read or modification.

## Current delivery links

- Feature branch: `feat/e1-donations-portal`
- Pull request: https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/pull/19
- Public site: https://empathetic-narwhal-9eroye-dev-ed.trailblaze.my.site.com/donaciones/

The public site URL currently loads the Experience Cloud page. The campaign data will become visible to anonymous visitors after pending item **P-01** is enabled and the site is republished.
