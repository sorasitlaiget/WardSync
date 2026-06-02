import { Request, Response, NextFunction } from 'express';
import * as usersService from './users.service';
import { CreateUserDto, CompleteProfileDto, UpdateUserRoleDto } from './users.types';

export async function getMyProfile(req: Request, res: Response, next: NextFunction) {
  try {
    const profile = await usersService.getProfile(req.user!.uid);
    res.json(profile);
  } catch (err) {
    next(err);
  }
}

export async function completeProfile(req: Request, res: Response, next: NextFunction) {
  try {
    const dto = req.body as CompleteProfileDto;
    const profile = await usersService.completeProfile(req.user!.uid, dto);
    res.json(profile);
  } catch (err) {
    next(err);
  }
}

export async function createUser(req: Request, res: Response, next: NextFunction) {
  try {
    const dto = req.body as CreateUserDto;
    const profile = await usersService.createUser(dto);
    res.status(201).json(profile);
  } catch (err) {
    next(err);
  }
}

export async function listUsers(req: Request, res: Response, next: NextFunction) {
  try {
    const users = await usersService.listUsers();
    res.json(users);
  } catch (err) {
    next(err);
  }
}

export async function updateFcmToken(req: Request, res: Response, next: NextFunction) {
  try {
    const { fcmToken } = req.body;
    await usersService.updateFcmToken(req.user!.uid, fcmToken);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
}

export async function updateUserRole(req: Request, res: Response, next: NextFunction) {
  try {
    const { uid } = req.params;
    const dto = req.body as UpdateUserRoleDto;
    const profile = await usersService.updateUserRole(uid, dto);
    res.json(profile);
  } catch (err) {
    next(err);
  }
}
