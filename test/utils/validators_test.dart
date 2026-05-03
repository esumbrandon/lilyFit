import 'package:flutter_test/flutter_test.dart';
import 'package:lilyfit/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns null for valid email addresses', () {
        expect(Validators.validateEmail('user@example.com'), isNull);
        expect(
          Validators.validateEmail('user.name+tag@sub.domain.org'),
          isNull,
        );
        expect(Validators.validateEmail('USER@EXAMPLE.COM'), isNull);
        expect(Validators.validateEmail('a1@b.co'), isNull);
      });

      test('returns error for null input', () {
        expect(Validators.validateEmail(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.validateEmail(''), isNotNull);
      });

      test('returns error for whitespace-only string', () {
        expect(Validators.validateEmail('   '), isNotNull);
      });

      test('returns error for missing @ symbol', () {
        expect(Validators.validateEmail('userexample.com'), isNotNull);
      });

      test('returns error for missing domain', () {
        expect(Validators.validateEmail('user@'), isNotNull);
      });

      test('returns error for missing TLD', () {
        expect(Validators.validateEmail('user@domain'), isNotNull);
      });

      test('returns error for TLD with only 1 character', () {
        expect(Validators.validateEmail('user@domain.c'), isNotNull);
      });

      test('required error message for empty', () {
        expect(Validators.validateEmail(''), 'Email is required');
      });

      test('format error message for invalid format', () {
        expect(
          Validators.validateEmail('not-an-email'),
          'Please enter a valid email address',
        );
      });
    });

    group('validateName', () {
      test('returns null for valid names', () {
        expect(Validators.validateName('Alice'), isNull);
        expect(Validators.validateName('John Doe'), isNull);
        expect(Validators.validateName('María García'), isNull);
        expect(Validators.validateName('12345'), isNull); // 5 chars
      });

      test('returns error for null input', () {
        expect(Validators.validateName(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.validateName(''), isNotNull);
      });

      test('returns error for whitespace-only string', () {
        expect(Validators.validateName('    '), isNotNull);
      });

      test('returns error for name shorter than 5 characters', () {
        expect(Validators.validateName('Al'), isNotNull);
        expect(Validators.validateName('Ali'), isNotNull);
        expect(Validators.validateName('Alic'), isNotNull);
      });

      test('returns null for name with exactly 5 characters', () {
        expect(Validators.validateName('Alice'), isNull);
      });

      test('required error message for empty input', () {
        expect(Validators.validateName(''), 'Name is required');
      });

      test('length error message for short name', () {
        expect(
          Validators.validateName('Ali'),
          'Name must be at least 5 characters',
        );
      });
    });

    group('validatePassword', () {
      test('returns null for valid passwords', () {
        expect(Validators.validatePassword('password'), isNull);
        expect(Validators.validatePassword('123456'), isNull);
        expect(Validators.validatePassword('P@ssw0rd!'), isNull);
      });

      test('returns error for null input', () {
        expect(Validators.validatePassword(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.validatePassword(''), isNotNull);
      });

      test('returns error for passwords shorter than 6 characters', () {
        expect(Validators.validatePassword('12345'), isNotNull);
        expect(Validators.validatePassword('ab'), isNotNull);
      });

      test('returns null for password with exactly 6 characters', () {
        expect(Validators.validatePassword('123456'), isNull);
      });

      test('required error message for empty input', () {
        expect(Validators.validatePassword(''), 'Password is required');
      });

      test('length error message for short password', () {
        expect(
          Validators.validatePassword('abc'),
          'Password must be at least 6 characters',
        );
      });
    });

    group('validateRequired', () {
      test('returns null for non-empty value', () {
        expect(Validators.validateRequired('some value', 'Field'), isNull);
        expect(Validators.validateRequired('0', 'Count'), isNull);
      });

      test('returns error for null input', () {
        expect(Validators.validateRequired(null, 'Email'), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.validateRequired('', 'City'), isNotNull);
      });

      test('returns error for whitespace-only input', () {
        expect(Validators.validateRequired('   ', 'Name'), isNotNull);
      });

      test('error message includes field name', () {
        expect(Validators.validateRequired('', 'City'), 'City is required');
        expect(Validators.validateRequired(null, 'Phone'), 'Phone is required');
      });
    });
  });
}
