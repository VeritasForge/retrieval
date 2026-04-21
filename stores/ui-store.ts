import { create } from "zustand";
import { persist } from "zustand/middleware";

type EditTaskTarget = {
  taskId: string;
  categoryId: string;
  strategyId: string;
  studyDate: string;
  title: string;
} | null;

type SectionKey = "today" | "completed" | "upcoming" | "overdue";

type UiStore = {
  sidebarCollapsed: boolean;
  toggleSidebar: () => void;
  addTaskModalOpen: boolean;
  openAddTaskModal: () => void;
  closeAddTaskModal: () => void;
  editTaskTarget: EditTaskTarget;
  openEditTaskModal: (target: NonNullable<EditTaskTarget>) => void;
  closeEditTaskModal: () => void;
  collapsedSections: Record<SectionKey, boolean>;
  toggleSection: (key: SectionKey) => void;
};

export const useUiStore = create<UiStore>()(
  persist(
    (set) => ({
      sidebarCollapsed: false,
      toggleSidebar: () => set((state) => ({ sidebarCollapsed: !state.sidebarCollapsed })),
      addTaskModalOpen: false,
      openAddTaskModal: () => set({ addTaskModalOpen: true }),
      closeAddTaskModal: () => set({ addTaskModalOpen: false }),
      editTaskTarget: null,
      openEditTaskModal: (target) => set({ editTaskTarget: target }),
      closeEditTaskModal: () => set({ editTaskTarget: null }),
      collapsedSections: { today: false, completed: false, upcoming: false, overdue: false },
      toggleSection: (key) =>
        set((state) => ({
          collapsedSections: {
            ...state.collapsedSections,
            [key]: !state.collapsedSections[key],
          },
        })),
    }),
    {
      name: "retrieval-ui",
      partialize: (state) => ({ collapsedSections: state.collapsedSections }),
    }
  )
);
