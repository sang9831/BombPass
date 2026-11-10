import { create } from 'zustand';
type GameStore = { roomId: string | null; setRoomId: (id: string | null) => void };
export const useGameStore = create<GameStore>((set) => ({ roomId: null, setRoomId: (roomId) => set({ roomId }) }));
