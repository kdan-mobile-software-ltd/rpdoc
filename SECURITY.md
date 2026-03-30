# Security Policy

## Scope

This policy applies to security vulnerabilities in the **rpdoc** gem itself.

`rpdoc` generates Postman collection data from RSpec request specs and can optionally push generated collections to the Postman API. Reports about security issues in your own application, infrastructure, test data, or secret management are out of scope unless the issue is caused by unsafe behavior in `rpdoc`.

## Supported Versions

Security fixes are generally provided for the latest maintained release line.

| Version | Supported |
| ------- | --------- |
| 0.3.x   | Yes       |
| < 0.3   | No        |

If you are using an older version, please upgrade to the latest release before reporting behavior that may already be fixed.

## Reporting a Vulnerability

Please report suspected vulnerabilities privately. Do **not** open a public GitHub issue for undisclosed security problems.

Preferred contact:

- Email: [dev@kdanmobile.com](mailto:dev@kdanmobile.com)

When possible, include:

- A clear description of the issue
- The affected version(s)
- Steps to reproduce the problem
- The expected impact
- Any proof of concept, logs, or suggested remediation

## Response Process

We will make a reasonable effort to:

- Acknowledge receipt of the report within 5 business days
- Investigate and validate the issue
- Share remediation plans or timelines when possible
- Coordinate disclosure once a fix or mitigation is available

## Disclosure Policy

Please allow reasonable time for investigation and remediation before disclosing vulnerabilities publicly. Coordinated disclosure helps protect users of the gem.

## Recommendations for Users

To reduce risk when using `rpdoc`:

- Do not commit Postman API keys or other secrets to source control
- Review generated request and response artifacts before sharing them, since example data may contain sensitive information
- Avoid using production secrets or production-only data in request specs that may be transformed into documentation artifacts

## Security Updates

Security-related fixes will be documented in the project changelog and released in the normal gem release process unless there is a reason to limit disclosure until users have time to upgrade.
