
import React, { useState } from 'react';
import SearchBar from '@/components/SearchBar';
import PatientCard, { Patient } from '@/components/PatientCard';
import PatientModal from '@/components/PatientModal';
import StatsCard from '@/components/StatsCard';
import { usePatientSearch } from '@/hooks/usePatientSearch';
import { Users, UserCheck, AlertTriangle, Activity } from 'lucide-react';

const Index = () => {
  const { searchTerm, setSearchTerm, filteredPatients, totalPatients } = usePatientSearch();
  const [selectedPatient, setSelectedPatient] = useState<Patient | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const handlePatientClick = (patient: Patient) => {
    setSelectedPatient(patient);
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setSelectedPatient(null);
  };

  // Calculate stats
  const activePatients = filteredPatients.filter(p => p.status === 'Active').length;
  const criticalPatients = filteredPatients.filter(p => p.status === 'Critical').length;
  const todayVisits = filteredPatients.filter(p => {
    const today = new Date().toISOString().split('T')[0];
    return p.lastVisit.includes(today);
  }).length;

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header - Mobile Optimized */}
      <div className="bg-white shadow-sm border-b border-gray-200">
        <div className="px-4 py-6">
          <div className="text-center">
            <h1 className="text-2xl sm:text-3xl font-bold text-gray-900 mb-2">
              Hospital Patient Management
            </h1>
            <p className="text-gray-600 text-sm mb-4">
              Manage and search through patient records efficiently
            </p>
            <div className="inline-flex items-center bg-blue-50 px-4 py-2 rounded-full">
              <p className="text-sm text-gray-500 mr-2">Total Patients</p>
              <p className="text-xl font-bold text-blue-600">{totalPatients.toLocaleString()}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="px-4 py-6">
        {/* Search Bar - Mobile Optimized */}
        <div className="mb-6">
          <SearchBar
            searchTerm={searchTerm}
            onSearchChange={setSearchTerm}
            placeholder="Search patients..."
          />
        </div>

        {/* Stats Cards - Mobile Grid */}
        <div className="grid grid-cols-2 gap-3 mb-6">
          <StatsCard
            title="Found"
            value={filteredPatients.length}
            icon={Users}
            color="text-blue-600"
          />
          <StatsCard
            title="Active"
            value={activePatients}
            icon={UserCheck}
            color="text-green-600"
          />
          <StatsCard
            title="Critical"
            value={criticalPatients}
            icon={AlertTriangle}
            color="text-red-600"
          />
          <StatsCard
            title="Recent"
            value={todayVisits}
            icon={Activity}
            color="text-purple-600"
          />
        </div>

        {/* Search Results Header */}
        {searchTerm && (
          <div className="mb-4">
            <h2 className="text-lg font-semibold text-gray-900 mb-1">
              Results ({filteredPatients.length})
            </h2>
            <p className="text-gray-600 text-sm">
              Searching for: <span className="font-medium">"{searchTerm}"</span>
            </p>
          </div>
        )}

        {/* Patient Cards - Mobile Single Column */}
        {filteredPatients.length > 0 ? (
          <div className="space-y-4">
            {filteredPatients.map((patient) => (
              <PatientCard
                key={patient.id}
                patient={patient}
                onClick={handlePatientClick}
              />
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <Users className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-gray-900 mb-2">No patients found</h3>
            <p className="text-gray-600 text-sm px-4">
              {searchTerm
                ? `No patients match your search for "${searchTerm}"`
                : "Start typing to search for patients"}
            </p>
          </div>
        )}
      </div>

      {/* Patient Detail Modal */}
      <PatientModal
        patient={selectedPatient}
        isOpen={isModalOpen}
        onClose={handleCloseModal}
      />
    </div>
  );
};

export default Index;
