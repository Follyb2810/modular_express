import bcrypt from 'bcrypt';

export class PasswordHasher {

  static async hashPassword(pwd: string): Promise<string> {
    try {
      const salt = await bcrypt.genSalt(10);
      return await bcrypt.hash(pwd, salt);
    } catch (error) {
      throw new Error('Error hashing password');
    }
  }


  static async comparePassword(password: string, hash: string): Promise<boolean> {
    try {
      return await bcrypt.compare(password, hash);
    } catch (error) {
      throw new Error('Error comparing passwords');
    }
  }
}
